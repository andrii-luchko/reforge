import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// Pedometer-based [TrackingEngine] for treadmill workouts.
///
/// Uses the device's built-in step counter (pedometer package) to derive
/// distance and pace. The step length is fixed at [_strideMeters] until
/// we can pull it from the user's profile.
///
/// Metric pipeline:
///   steps → distance = steps × [_strideMeters]
///   pace (km/h) = (distance / duration) × 3.6
///
/// Registered as the default [TrackingEngine] in the DI container.
/// The GPS implementation will be registered as an alternative in Phase 5.
@Injectable(as: TrackingEngine)
@Named('pedometer')
class PedometerTrackingEngine implements TrackingEngine {
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

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_tickTimer != null) return; // Already tracking — ignore.

    _isPaused = false;

    if (initialOffset != null) {
      _durationSeconds = initialOffset.durationSeconds;
      _lapSteps = initialOffset.stepCount;
    } else {
      _durationSeconds = 0;
      _lapSteps = 0;
    }
    _baselineStepCount = 0;

    logger.d('PedometerTrackingEngine: starting');

    // Subscribe to the device step counter.
    _stepSub = Pedometer.stepCountStream.listen(
      _onStep,
      onError: (Object e) {
        logger.e('PedometerTrackingEngine: step stream error: $e');
        _controller.addError(e);
      },
      cancelOnError: false,
    );

    // Wall-clock tick to increment duration and emit metrics every second.
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  @override
  void pause() {
    _isPaused = true;
    logger.d('PedometerTrackingEngine: paused');
  }

  @override
  void resume() {
    _isPaused = false;
    logger.d('PedometerTrackingEngine: resumed');
  }

  @override
  void stop() {
    unawaited(_stepSub?.cancel());
    _stepSub = null;
    _tickTimer?.cancel();
    _tickTimer = null;
    _isPaused = false;
    logger.d('PedometerTrackingEngine: stopped');
  }

  @override
  void reset() {
    _lapSteps = 0;
    _durationSeconds = 0;
    _baselineStepCount = 0;
    logger.d('PedometerTrackingEngine: metrics reset');
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
    stop();
    unawaited(_controller.close());
  }
}
