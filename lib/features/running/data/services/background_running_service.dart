import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/app/di/background_injector.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

Future<void> initializeBackgroundService() async {
  if (Platform.isAndroid) {
    const channel = AndroidNotificationChannel(
      RunningConstants.notificationChannelId,
      'Workout Tracker',
      description: 'Used for active workout tracking',
      importance: Importance.low,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

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
      notificationChannelId: RunningConstants.notificationChannelId,
      initialNotificationTitle: RunningConstants.notificationTitle,
      initialNotificationContent: RunningConstants.notificationText,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
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
      StreamSubscription<RunningEvent>? eventsSub;

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
          final startPaused = event['startPaused'] as bool? ?? false;
          final mode = RunningMode.values.firstWhere((m) => m.name == modeStr);

          final rawLimits = event['limits'] as List<dynamic>? ?? [];
          final limits = rawLimits.map((l) {
            final map = l as Map<String, dynamic>;
            final metricName = map['metric'] as String;
            return LapLimit(
              metric: WorkoutMetric.values.firstWhere((m) => m.name == metricName),
              limitValue: (map['limitValue'] as num).toDouble(),
              segmentId: map['segmentId'] as int?,
              activityType: SegmentActivity.values.firstWhere(
                (a) => a.name == (map['activityType'] as String?),
                orElse: () => SegmentActivity.run,
              ),
            );
          }).toList();

          // Attach first: a synchronous startup error or first metric must not
          // be lost between manager.startSession() and stream subscription.
          await metricsSub?.cancel();
          metricsSub = manager.metricsStream.listen(
            (metrics) {
              service.invoke('metrics', {
                'distanceMeters': metrics.distanceMeters,
                'durationSeconds': metrics.durationSeconds,
                'avgSpeedKmH': metrics.avgSpeedKmH,
                'currentSpeedKmH': metrics.currentSpeedKmH,
                'avgPaceMinKm': metrics.avgPaceMinKm,
                'currentPaceMinKm': metrics.currentPaceMinKm,
                'stepCount': metrics.stepCount,
                'currentSegmentIndex': metrics.currentSegmentIndex,
                'segmentId': metrics.segmentId,
                'activityType': metrics.activityType.name,
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
              final isFatal = e is SensorUnavailableException;
              service.invoke('sensor_error', {
                'code': isFatal ? 'sensor_unavailable' : 'sensor_stream_error',
                'message': e.toString(),
                'isFatal': isFatal,
              });
            },
            cancelOnError: false,
          );

          await eventsSub?.cancel();
          eventsSub = manager.eventsStream.listen(
            (event) {
              if (event is LapCompletedEvent) {
                service.invoke('events', {
                  'type': 'LapCompletedEvent',
                  'segmentIndex': event.segmentIndex,
                  'segmentId': event.segmentId,
                });
              } else if (event is PlannedWorkoutCompletedEvent) {
                service.invoke('events', {
                  'type': 'PlannedWorkoutCompletedEvent',
                });
              }
            },
            onError: (Object e, StackTrace st) {
              logger.e('Background: events stream error', e, st);
            },
            cancelOnError: false,
          );

          // Teleport Guard
          await _handleSessionRestore(sessionId);

          await manager.startSession(
            mode: mode,
            limits: limits,
            sessionId: sessionId,
            programExerciseId: programExerciseId,
            startPaused: startPaused,
          );
        } on Object catch (e, st) {
          logger.e('Background: Error in start_session', e, st);
          service.invoke('sensor_error', {
            'code': 'session_start_failed',
            'message': e.toString(),
            'isFatal': true,
          });
        }
      });

      // 3. Pause
      service.on('pause_session').listen((_) {
        try {
          manager.pauseSession();
        } on Exception catch (e, st) {
          logger.e('Background: Error in pause_session', e, st);
        }
      });

      // 4. Resume
      service.on('resume_session').listen((_) async {
        try {
          await manager.resumeSession();
        } on Exception catch (e, st) {
          logger.e('Background: Error in resume_session', e, st);
        }
      });

      // 5. Suspend for Summary (Free run stop logic)
      service.on('suspend_session').listen((_) async {
        try {
          await manager.suspendSessionForSummary();
        } on Exception catch (e, st) {
          logger.e('Background: Error in suspend_session', e, st);
        }
      });

      // 6. Force Next Lap (Manual skip)
      service.on('force_next_lap').listen((_) {
        try {
          manager.forceNextLap();
        } on Exception catch (e, st) {
          logger.e('Background: Error in force_next_lap', e, st);
        }
      });

      // 7. Stop (End and dispose)
      service.on('stop_session').listen((_) async {
        try {
          await metricsSub?.cancel();
          await eventsSub?.cancel();
          manager.endSession();
        } on Exception catch (e, st) {
          logger.e('Background: Error in stop_session', e, st);
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
    (error, stack) async {
      // An unhandled exception escaped all individual try/catch blocks.
      // This is a fatal error for the background isolate.
      logger.e('Background: FATAL unhandled error. Stopping service.', error, stack);
      service.invoke('fatal_error', {
        'code': 'background_service_failed',
        'message': error.toString(),
        'isFatal': true,
      });
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
