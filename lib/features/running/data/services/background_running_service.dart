import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/app/di/background_injector.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      foregroundServiceTypes: [
        AndroidForegroundType.location,
        AndroidForegroundType.dataSync,
      ],
      notificationChannelId: 'running_tracker',
      initialNotificationTitle: 'Reforge',
      initialNotificationContent: 'Tracking active workout',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global safety net ─────────────────────────────────────────────────────
  // Any unhandled exception inside the background isolate that escapes all
  // individual try/catch blocks will be caught here. We notify the UI and
  // stop the service cleanly rather than leaving it in a zombie state.
  await runZonedGuarded(
    () async {
      await configureBackgroundDependencies();
      final manager = backgroundGetIt<RunningSessionManager>();
      StreamSubscription<RunningMetrics>? metricsSub;

      // 1. Ping-Pong
      service.on('ping').listen((_) {
        service.invoke('pong', {
          'isRunning': manager.currentMode != null,
        });
      });

      // 2. Start / Restore Session
      service.on('start_session').listen((event) async {
        if (event == null) return;
        try {
          final sessionId = event['sessionId'] as int;
          final programExerciseId = event['programExerciseId'] as int;
          final modeStr = event['mode'] as String;
          final mode = RunningMode.values.firstWhere((m) => m.name == modeStr);

          final rawLimits = event['limits'] as List<dynamic>? ?? [];
          final limits = rawLimits.map((l) {
            final map = l as Map<String, dynamic>;
            final metricName = map['metric'] as String;
            return LapLimit(
              metric: WorkoutMetric.values.firstWhere((m) => m.name == metricName),
              limitValue: (map['limitValue'] as num).toDouble(),
            );
          }).toList();

          // Teleport Guard
          await _handleSessionRestore(sessionId);

          await manager.startSession(
            mode: mode,
            limits: limits,
            sessionId: sessionId,
            programExerciseId: programExerciseId,
          );

          await metricsSub?.cancel();
          metricsSub = manager.metricsStream.listen(
            (metrics) {
              service.invoke('metrics', {
                'distanceMeters': metrics.distanceMeters,
                'durationSeconds': metrics.durationSeconds,
                'paceKmH': metrics.paceKmH,
                'stepCount': metrics.stepCount,
                'currentSegmentIndex': metrics.currentSegmentIndex,
                'lapJustCompleted': metrics.lapJustCompleted,
                if (metrics.currentLocation != null) 'lat': metrics.currentLocation!.latitude,
                if (metrics.currentLocation != null) 'lng': metrics.currentLocation!.longitude,
                if (metrics.currentLocation != null) 'heading': metrics.currentLocation!.heading,
              });
            },
            onError: (Object e, StackTrace st) {
              // Engine errors (SensorUnavailableException, GPS dropout) are
              // forwarded to the UI as a 'sensor_error' event. The session
              // continues — the timer keeps running even without sensor data.
              logger.e('Background: metrics stream error', e, st);
              service.invoke('sensor_error', {'message': e.toString()});
            },
            cancelOnError: false,
          );
        } on Exception catch (e, st) {
          logger.e('Background: Error in start_session', e, st);
          service.invoke('sensor_error', {'message': e.toString()});
        }
      });

      // 3. Pause
      service.on('pause_session').listen((_) {
        try {
          manager.pauseSession();
        } on Exception catch (e) {
          logger.e('Background: Error in pause_session: $e');
        }
      });

      // 4. Resume
      service.on('resume_session').listen((_) async {
        try {
          await manager.resumeSession();
        } on Exception catch (e) {
          logger.e('Background: Error in resume_session: $e');
        }
      });

      // 5. Suspend for Summary (Free run stop logic)
      service.on('suspend_session').listen((_) async {
        try {
          await manager.suspendSessionForSummary();
        } on Exception catch (e) {
          logger.e('Background: Error in suspend_session: $e');
        }
      });

      // 6. Force Next Lap (Manual skip)
      service.on('force_next_lap').listen((_) {
        try {
          manager.forceNextLap();
        } on Exception catch (e) {
          logger.e('Background: Error in force_next_lap: $e');
        }
      });

      // 7. Stop (End and dispose)
      service.on('stop_session').listen((_) async {
        try {
          await metricsSub?.cancel();
          manager.endSession();
        } on Exception catch (e) {
          logger.e('Background: Error in stop_session: $e');
        } finally {
          await service.stopSelf();
        }
      });

      // ── Handshake: Signal that the isolate is fully initialized ────────────
      // This MUST be the last line of the setup block. The UI-side
      // RunningServiceClient waits for this event before sending 'start_session'.
      // Without it, there is a race condition where the command arrives before
      // the listeners above are registered.
      service.invoke('service_ready');
    },
    (Object error, StackTrace stack) async {
      // An unhandled exception escaped all individual try/catch blocks.
      // This is a fatal error for the background isolate.
      logger.e('Background: FATAL unhandled error. Stopping service.', error, stack);
      service.invoke('fatal_error', {'message': error.toString()});
      await service.stopSelf();
    },
  );
}

Future<void> _handleSessionRestore(int sessionId) async {
  try {
    final repo = backgroundGetIt<LocalWorkoutSessionRepository>();
    final inProgressLap = await repo.getInProgressLap(sessionId);
    if (inProgressLap == null) return;

    final lastSnapshotAt = inProgressLap.lastSnapshotAt;
    if (lastSnapshotAt == null) return;

    final staleness = DateTime.now().difference(lastSnapshotAt);

    // Rule 1: Stale Session Check
    if (staleness > RunningConstants.maxSessionStaleness) {
      logger.d('Background: Session is stale ($staleness). Auto-finishing.');
      await repo.markSetAsDone(inProgressLap.id);
      return;
    }

    // Rule 2: Teleport Guard (GPS only)
    if (inProgressLap.trackingMode == RunningMode.gps.dbValue && staleness.inSeconds > 0) {
      final points = await repo.getRoutePoints(sessionId);
      final lastPos = points.lastOrNull;
      if (lastPos != null) {
        final currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        final distanceM = Geolocator.distanceBetween(
          lastPos.latitude,
          lastPos.longitude,
          currentPos.latitude,
          currentPos.longitude,
        );

        final speedKmh = (distanceM / staleness.inSeconds) * 3.6;
        if (speedKmh > RunningConstants.maxHumanSpeedKmh) {
          logger.d('Background: Teleport detected ($speedKmh km/h). Auto-finishing.');
          await repo.markSetAsDone(inProgressLap.id);
        }
      }
    }
  } on Exception catch (e, st) {
    logger.e('Background: Error in _handleSessionRestore', e, st);
  }
}
