// ignore_for_file: unused_import

import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/services/running_tracking_service.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';

/// Pedometer-based [RunningTrackingService] for treadmill workouts.
///
/// Uses the device's built-in step counter (pedometer package) to derive
/// distance and pace. The step length is fixed at [_strideMeters] until
/// we can pull it from the user's profile.
///
/// Metric pipeline:
///   steps → distance = steps × [_strideMeters]
///   pace (km/h) = (distance / duration) × 3.6
///
/// Registered as the default [RunningTrackingService] in the DI container.
/// The GPS implementation will be registered as an alternative in Phase 5.
@lazySingleton
class PedometerTrackingService implements RunningTrackingService {
  /// Average stride length in metres. Industry standard is ~0.78 m.
  // TODO(running-module): derive from user height / profile.
  static const double _strideMeters = 0.78;

  /// Ticker interval — we derive duration from a wall-clock stopwatch rather
  /// than relying on the pedometer timestamp, which varies per device.
  static const _tickInterval = Duration(seconds: 1);

  // ── State ──────────────────────────────────────────────────────────────────

  final _controller = StreamController<RunningMetrics>.broadcast();

  StreamSubscription<StepCount>? _stepSub;
  Timer? _tickTimer;

  int _baselineStepCount = 0; // platform step counter at the moment tracking started
  int _lapSteps = 0; // steps accumulated in this lap
  int _durationSeconds = 0; // elapsed seconds in this lap
  bool _isPaused = false;

  RunningMode? _mode;

  // ── RunningTrackingService ─────────────────────────────────────────────────

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  RunningMode? get currentMode => _mode;

  @override
  Future<void> startTracking({
    required RunningMode mode,
    required List<LapLimit> limits,
    RunningMetrics? initialOffset,
    int? workoutSessionId,
    int? programExerciseId,
  }) async {
    if (_mode != null) return; // Already tracking — ignore.

    _mode = mode;
    _isPaused = false;
    
    if (initialOffset != null) {
      _durationSeconds = initialOffset.durationSeconds;
      _lapSteps = initialOffset.stepCount;
    } else {
      _durationSeconds = 0;
      _lapSteps = 0;
    }
    _baselineStepCount = 0;

    logger.d('PedometerTrackingService: starting (mode: ${mode.dbValue})');

    // Subscribe to the device step counter.
    _stepSub = Pedometer.stepCountStream.listen(
      _onStep,
      onError: (Object e) {
        logger.e('PedometerTrackingService: step stream error: $e');
        _controller.addError(e);
      },
      cancelOnError: false,
    );

    // Wall-clock tick to increment duration and emit metrics every second.
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  @override
  void pauseTracking() {
    _isPaused = true;
    logger.d('PedometerTrackingService: paused');
  }

  @override
  void resumeTracking() {
    _isPaused = false;
    logger.d('PedometerTrackingService: resumed');
  }

  @override
  void forceNextLap() {
    // Leaf trackers don't manage laps; this is handled by RunningTrackingManager.
  }

  @override
  void stopTracking() {
    unawaited(_stepSub?.cancel());
    _stepSub = null;
    _tickTimer?.cancel();
    _tickTimer = null;
    _mode = null;
    _isPaused = false;
    logger.d('PedometerTrackingService: stopped');
  }

  @override
  void resetMetrics() {
    _lapSteps = 0;
    _durationSeconds = 0;
    _baselineStepCount = 0;
    logger.d('PedometerTrackingService: metrics reset');
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _onStep(StepCount event) {
    if (_isPaused) return;

    if (_baselineStepCount == 0) {
      // First event after (re-)start — record baseline so lap starts from 0.
      _baselineStepCount = event.steps;
    }

    _lapSteps = event.steps - _baselineStepCount;
  }

  void _onTick() {
    if (_isPaused) return;

    _durationSeconds++;

    final distanceMeters = _lapSteps * _strideMeters;
    final paceKmH = _durationSeconds > 0 ? (distanceMeters / _durationSeconds) * 3.6 : 0.0;

    _controller.add(
      RunningMetrics(
        distanceMeters: distanceMeters,
        durationSeconds: _durationSeconds,
        paceKmH: paceKmH,
        stepCount: _lapSteps,
      ),
    );
  }

  /// Dispose when the singleton is torn down (e.g. during testing).
  void dispose() {
    stopTracking();
    unawaited(_controller.close());
  }
}
