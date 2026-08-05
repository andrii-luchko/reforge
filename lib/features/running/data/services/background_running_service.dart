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
import 'package:reforge/features/running/domain/services/treadmill_speed_validation.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

Future<void> initializeBackgroundService({RunningMode? mode}) async {
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
      foregroundServiceTypes: androidForegroundServiceTypesForMode(mode),
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

List<AndroidForegroundType> androidForegroundServiceTypesForMode(
  RunningMode? mode,
) {
  return switch (mode) {
    RunningMode.gps || RunningMode.treadmill || null => const [
      AndroidForegroundType.location,
    ],
  };
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
          'exerciseSessionId:${event['exerciseSessionId']?.runtimeType},'
          'workoutProgramExerciseId:${event['workoutProgramExerciseId']?.runtimeType}',
        );
        try {
          final sessionId = RunningServiceProtocol.requiredInt(event, 'sessionId');
          final exerciseSessionId = RunningServiceProtocol.requiredInt(event, 'exerciseSessionId');
          final workoutProgramExerciseId = RunningServiceProtocol.optionalInt(
            event,
            'workoutProgramExerciseId',
          );
          final modeStr = RunningServiceProtocol.requiredString(event, 'mode');
          final startPaused = RunningServiceProtocol.optionalBool(event, 'startPaused', fallback: false);
          final restoreCompletedPlan = RunningServiceProtocol.optionalBool(
            event,
            'restoreCompletedPlan',
            fallback: false,
          );
          final mode = RunningMode.values.firstWhere((m) => m.name == modeStr);
          final initialSpeedKmH = RunningServiceProtocol.initialTreadmillSpeed(
            event,
            mode,
          );

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
              logger.e('Background: metrics stream error', e, st);
              final payload = _sensorErrorPayload(e);
              service.invoke('sensor_error', {
                'code': payload.code,
                'message': payload.message,
                'isFatal': payload.isFatal,
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
          await _handleSessionRestore(
            sessionId,
            exerciseSessionId,
            workoutProgramExerciseId,
          );

          _logBackground(
            'manager_start_begin mode=$mode startPaused=$startPaused '
            'restoreCompletedPlan=$restoreCompletedPlan',
          );
          await manager.startSession(
            mode: mode,
            limits: limits,
            sessionId: sessionId,
            exerciseSessionId: exerciseSessionId,
            workoutProgramExerciseId: workoutProgramExerciseId,
            startPaused: startPaused,
            restoreCompletedPlan: restoreCompletedPlan,
            initialSpeedKmH: initialSpeedKmH,
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
          final payload = switch (e) {
            ServiceProtocolException() => (
              code: 'service_protocol_error',
              message: 'The tracking service returned invalid data.',
              isFatal: true,
            ),
            TrackingEngineFailureException() => _sensorErrorPayload(e),
            _ => (
              code: 'session_start_failed',
              message: 'The tracking session could not be started.',
              isFatal: true,
            ),
          };
          service.invoke('sensor_error', {
            'code': payload.code,
            'message': payload.message,
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

      // 6. Apply a canonical manual treadmill speed without pausing tracking.
      service.on('set_treadmill_speed').listen((event) async {
        _logBackground('set_treadmill_speed_received');
        try {
          if (event == null) {
            throw const ServiceProtocolException(
              key: 'set_treadmill_speed',
              expectedType: 'Map',
              actualValue: null,
            );
          }
          final speedKmH = RunningServiceProtocol.requiredDouble(
            event,
            'speedKmH',
          );
          TreadmillSpeedValidation.validate(speedKmH);
          await manager.setTreadmillSpeed(speedKmH);
          _logBackground('set_treadmill_speed_applied');
        } on Object catch (e, st) {
          logger.e('Background: Error in set_treadmill_speed', e, st);
          final payload = switch (e) {
            ServiceProtocolException() || ArgumentError() => (
              code: 'invalid_treadmill_speed',
              message: 'Enter a treadmill speed greater than zero.',
            ),
            StateError() => (
              code: 'treadmill_speed_unavailable',
              message: 'Treadmill speed can only be changed during a treadmill run.',
            ),
            _ => (
              code: 'treadmill_speed_update_failed',
              message: 'The treadmill speed could not be updated.',
            ),
          };
          service.invoke('sensor_error', {
            'code': payload.code,
            'message': payload.message,
            'isFatal': false,
          });
        }
      });

      // 7. Stop the session. Android also tears down its foreground service;
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

Future<void> _handleSessionRestore(
  int sessionId,
  int exerciseSessionId,
  int? workoutProgramExerciseId,
) async {
  try {
    final repo = backgroundGetIt<LocalWorkoutSessionRepository>();
    final inProgressLap = await repo.getInProgressLapForExercise(
      sessionId: sessionId,
      exerciseSessionId: exerciseSessionId,
      workoutProgramExerciseId: workoutProgramExerciseId,
    );
    if (inProgressLap == null) return;

    final lastSnapshotAt = inProgressLap.lastSnapshotAt;
    if (lastSnapshotAt == null) return;

    final staleness = DateTime.now().difference(lastSnapshotAt);

    // Rule 1: Stale Session Check
    if (staleness > RunningConstants.maxSessionStaleness) {
      logger.d('Background: Session is stale ($staleness). Auto-finishing.');
      await repo.markSetAsFinishedLocally(inProgressLap.id);
      return;
    }

    // Rule 2: Teleport Guard (GPS only)
    if (inProgressLap.trackingMode == RunningMode.gps.dbValue && staleness.inSeconds > 0) {
      final points = await repo.getRoutePoints(
        sessionId: sessionId,
        exerciseSessionId: exerciseSessionId,
        workoutProgramExerciseId: workoutProgramExerciseId,
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
          await repo.markSetAsFinishedLocally(inProgressLap.id);
        }
      }
    }
  } on Exception catch (e, st) {
    logger.e('Background: Error in _handleSessionRestore', e, st);
  }
}

({String code, String message, bool isFatal}) _sensorErrorPayload(Object error) {
  if (error case TrackingEngineFailureException(:final reason)) {
    return (
      code: switch (reason) {
        TrackingEngineFailureReason.locationServiceDisabled => 'location_service_disabled',
        TrackingEngineFailureReason.locationPermissionDenied => 'location_permission_denied',
        TrackingEngineFailureReason.sensorUnavailable => 'sensor_unavailable',
        TrackingEngineFailureReason.streamClosed => 'sensor_stream_closed',
        TrackingEngineFailureReason.unrecoverableStreamFailure => 'sensor_stream_failed',
      },
      message: switch (reason) {
        TrackingEngineFailureReason.locationServiceDisabled =>
          'Location services were turned off. Tracking has stopped.',
        TrackingEngineFailureReason.locationPermissionDenied =>
          'Location permission was removed. Tracking has stopped.',
        TrackingEngineFailureReason.sensorUnavailable => 'A required tracking sensor is unavailable.',
        TrackingEngineFailureReason.streamClosed ||
        TrackingEngineFailureReason.unrecoverableStreamFailure => 'The tracking sensor stopped unexpectedly.',
      },
      isFatal: true,
    );
  }

  return (
    code: 'sensor_stream_error',
    message: 'A tracking sensor is temporarily unavailable.',
    isFatal: false,
  );
}
