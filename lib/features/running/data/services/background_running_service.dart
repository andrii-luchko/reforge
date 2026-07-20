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
import 'package:reforge/features/running/data/services/running_service_protocol.dart';
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
        AndroidForegroundType.health,
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
  final bootstrapStopwatch = Stopwatch()..start();

  // ── Global safety net ─────────────────────────────────────────────────────
  // Any unhandled exception inside the background isolate that escapes all
  // individual try/catch blocks will be caught here. We notify the UI and
  // stop the service cleanly rather than leaving it in a zombie state.
  await runZonedGuarded(
    () async {
      _logBackground('on_start_entered');
      DartPluginRegistrant.ensureInitialized();
      WidgetsFlutterBinding.ensureInitialized();

      final dependenciesStartedAt = DateTime.now();
      _logBackground('dependencies_begin');
      await configureBackgroundDependencies();
      _logBackground('dependencies_elapsedMs=${DateTime.now().difference(dependenciesStartedAt).inMilliseconds}');
      final manager = backgroundGetIt<RunningSessionManager>();
      StreamSubscription<RunningMetrics>? metricsSub;
      StreamSubscription<RunningEvent>? eventsSub;
      Timer? firstMetricTimer;
      var firstMetricForwarded = false;

      // 1. Start / Restore Session
      service.on('start_session').listen((event) async {
        if (event == null) return;
        _logBackground(
          'start_session_received payloadTypes= '
          'sessionId:${event['sessionId']?.runtimeType},'
          'programExerciseId:${event['programExerciseId']?.runtimeType}',
        );
        try {
          final sessionId = RunningServiceProtocol.requiredInt(event, 'sessionId');
          final programExerciseId = RunningServiceProtocol.requiredInt(event, 'programExerciseId');
          final modeStr = RunningServiceProtocol.requiredString(event, 'mode');
          final startPaused = RunningServiceProtocol.optionalBool(event, 'startPaused', fallback: false);
          final mode = RunningMode.values.firstWhere((m) => m.name == modeStr);

          final rawLimits = RunningServiceProtocol.optionalList(event, 'limits');
          final limits = rawLimits.map((rawLimit) {
            final map = RunningServiceProtocol.stringMap(rawLimit, key: 'limits[]');
            final metricName = RunningServiceProtocol.requiredString(map, 'metric');
            return LapLimit(
              metric: WorkoutMetric.values.firstWhere((m) => m.name == metricName),
              limitValue: RunningServiceProtocol.requiredDouble(map, 'limitValue'),
              segmentId: RunningServiceProtocol.optionalInt(map, 'segmentId'),
              activityType: SegmentActivity.values.firstWhere(
                (a) => a.name == RunningServiceProtocol.optionalString(map, 'activityType'),
                orElse: () => SegmentActivity.run,
              ),
            );
          }).toList();

          firstMetricForwarded = false;
          firstMetricTimer?.cancel();

          // Attach first: a synchronous startup error or first metric must not
          // be lost between manager.startSession() and stream subscription.
          await metricsSub?.cancel();
          metricsSub = manager.metricsStream.listen(
            (metrics) {
              if (!firstMetricForwarded) {
                firstMetricForwarded = true;
                firstMetricTimer?.cancel();
                _logBackground('first_metric_forwarded');
              }
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
          await _handleSessionRestore(sessionId, programExerciseId);

          _logBackground('manager_start_begin mode=$mode startPaused=$startPaused');
          await manager.startSession(
            mode: mode,
            limits: limits,
            sessionId: sessionId,
            programExerciseId: programExerciseId,
            startPaused: startPaused,
          );
          _logBackground('manager_start_complete');

          if (!firstMetricForwarded && !startPaused) {
            firstMetricTimer = Timer(const Duration(seconds: 3), () {
              if (firstMetricForwarded) return;
              _logBackground('first_metric_timeout', error: true);
            });
          }
        } on Object catch (e, st) {
          logger.e('Background: Error in start_session', e, st);
          service.invoke('sensor_error', {
            'code': e is ServiceProtocolException ? 'service_protocol_error' : 'session_start_failed',
            'message': e.toString(),
            'isFatal': true,
          });
        }
      });

      // 2. Pause
      service.on('pause_session').listen((_) {
        _logBackground('pause_session_received');
        try {
          manager.pauseSession();
        } on Exception catch (e, st) {
          logger.e('Background: Error in pause_session', e, st);
        }
      });

      // 3. Resume
      service.on('resume_session').listen((_) async {
        _logBackground('resume_session_received');
        try {
          await manager.resumeSession();
        } on Exception catch (e, st) {
          logger.e('Background: Error in resume_session', e, st);
        }
      });

      // 4. Suspend for Summary (Free run stop logic)
      service.on('suspend_session').listen((_) async {
        _logBackground('suspend_session_received');
        try {
          await manager.suspendSessionForSummary();
        } on Exception catch (e, st) {
          logger.e('Background: Error in suspend_session', e, st);
        }
      });

      // 5. Force Next Lap (Manual skip)
      service.on('force_next_lap').listen((_) {
        _logBackground('force_next_lap_received');
        try {
          manager.forceNextLap();
        } on Exception catch (e, st) {
          logger.e('Background: Error in force_next_lap', e, st);
        }
      });

      // 6. Stop the session. Android also tears down its foreground service;
      // iOS keeps the initialized worker idle for the next workout.
      service.on('stop_session').listen((_) async {
        _logBackground('stop_session_received');
        try {
          firstMetricTimer?.cancel();
          firstMetricTimer = null;
          firstMetricForwarded = false;

          final currentMetricsSub = metricsSub;
          final currentEventsSub = eventsSub;
          metricsSub = null;
          eventsSub = null;

          await currentMetricsSub?.cancel();
          await currentEventsSub?.cancel();
          await manager.endSession();
        } on Object catch (e, st) {
          logger.e('Background: Error in stop_session', e, st);
          service.invoke('fatal_error', {
            'code': 'session_stop_failed',
            'message': e.toString(),
            'isFatal': true,
          });
          await service.stopSelf();
          return;
        }

        if (Platform.isAndroid) {
          _logBackground('session_stopped worker_shutdown_android');
          await service.stopSelf();
        } else {
          _logBackground('session_stopped worker_idle_ios');
        }
      });

      // Diagnostic only. The client never waits for this event.
      _logBackground('listeners_registered');
      service.invoke('service_ready', {
        'timestamp': DateTime.now().toIso8601String(),
        'protocolVersion': 1,
        'bootstrapElapsedMs': bootstrapStopwatch.elapsedMilliseconds,
      });
      _logBackground('service_ready_sent');
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

void _logBackground(String stage, {bool error = false}) {
  final message = '[BackgroundRunningService][${DateTime.now().toIso8601String()}] $stage';
  if (error) {
    logger.e(message);
  } else {
    logger.d(message);
  }
}

Future<void> _handleSessionRestore(int sessionId, int programExerciseId) async {
  try {
    final repo = backgroundGetIt<LocalWorkoutSessionRepository>();
    final inProgressLap = await repo.getInProgressLapForExercise(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
    );
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
      final points = await repo.getRoutePoints(
        sessionId: sessionId,
        programExerciseId: programExerciseId,
      );
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
