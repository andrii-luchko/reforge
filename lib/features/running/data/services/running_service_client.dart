import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

/// A UI-isolate client for communicating with the [FlutterBackgroundService].
///
/// This class provides an identical API to [RunningSessionManager], but instead
/// of managing the engines directly, it delegates all commands to the background
/// isolate via [ServiceInstance.invoke] and listens to metrics events.
@lazySingleton
class RunningServiceClient {
  RunningServiceClient() : _service = FlutterBackgroundService();
  final FlutterBackgroundService _service;

  final _metricsController = StreamController<RunningMetrics>.broadcast();
  bool _isListening = false;
  RunningMode? _currentMode;

  Stream<RunningMetrics> get metricsStream => _metricsController.stream;
  RunningMode? get currentMode => _currentMode;

  /// Subscribes to events from the background service.
  /// Must be called before starting the service or listening to metrics.
  Future<void> initialize() async {
    if (_isListening) return;
    _isListening = true;

    _service.on('metrics').listen((event) {
      if (event == null) return;

      final metrics = RunningMetrics(
        distanceMeters: (event['distanceMeters'] as num).toDouble(),
        durationSeconds: event['durationSeconds'] as int,
        avgSpeedKmH: (event['avgSpeedKmH'] as num).toDouble(),
        currentSpeedKmH: (event['currentSpeedKmH'] as num).toDouble(),
        avgPaceMinKm: (event['avgPaceMinKm'] as num).toDouble(),
        currentPaceMinKm: (event['currentPaceMinKm'] as num).toDouble(),
        stepCount: event['stepCount'] as int,
        currentSegmentIndex: event['currentSegmentIndex'] as int? ?? 0,
        lapJustCompleted: event['lapJustCompleted'] as bool? ?? false,
        segmentId: event['segmentId'] as int?,
        activityType: SegmentActivity.values.firstWhere(
          (a) => a.name == (event['activityType'] as String?),
          orElse: () => SegmentActivity.run,
        ),
        currentLocation: event['lat'] != null && event['lng'] != null
            ? RouteCoordinate(
                latitude: (event['lat'] as num).toDouble(),
                longitude: (event['lng'] as num).toDouble(),
                heading: (event['heading'] as num?)?.toDouble() ?? 0.0,
              )
            : null,
      );
      _metricsController.add(metrics);
    });
  }

  Future<bool> get isRunning async {
    return _service.isRunning();
  }

  Future<void> startSession({
    required RunningMode mode,
    required List<LapLimit> limits,
    required int sessionId,
    required int programExerciseId,
  }) async {
    _currentMode = mode;
    await initialize();

    final isServiceRunning = await _service.isRunning();
    if (!isServiceRunning) {
      await _service.startService();

      // ── Handshake: wait until the background isolate is fully ready ──────
      // The background isolate sends 'service_ready' as the very last step of
      // onStart(), after all event listeners are registered. Waiting for this
      // event guarantees that 'start_session' won't arrive before the isolate
      // is listening for it (Race Condition fix).
      // A 5-second timeout guards against the service failing to start.
      await _service
          .on('service_ready')
          .first
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );
    }

    _service.invoke('start_session', {
      'sessionId': sessionId,
      'programExerciseId': programExerciseId,
      'mode': mode.name,
      'limits': limits
          .map(
            (l) => {
              'metric': l.metric.name,
              'limitValue': l.limitValue,
              'segmentId': l.segmentId,
              'activityType': l.activityType.name,
            },
          )
          .toList(),
    });
  }

  void pauseSession() {
    _service.invoke('pause_session');
  }

  void resumeSession() {
    _service.invoke('resume_session');
  }

  void suspendSessionForSummary() {
    _service.invoke('suspend_session');
  }

  void forceNextLap() {
    _service.invoke('force_next_lap');
  }

  void endSession() {
    _currentMode = null;
    _service.invoke('stop_session');
  }
}
