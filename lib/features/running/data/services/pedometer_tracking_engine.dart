import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
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
class PedometerTrackingEngine implements TrackingEngine {
  /// Average stride length in metres. Industry standard is ~0.78 m.
  // TODO(running-module): derive from user height / profile.
  static const double _strideMeters = RunningConstants.defaultStrideMeters;

  /// Ticker interval — we derive duration from a wall-clock stopwatch rather
  /// than relying on the pedometer timestamp, which varies per device.
  static const Duration _tickInterval = RunningConstants.engineTickInterval;

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
      onError: (Object e, StackTrace st) {
        // PlatformException code 3 = "Step Count is not available" — the
        // hardware sensor is physically absent (simulator, some tablets).
        // This is FATAL for this session: no point retrying.
        if (e is PlatformException && e.code == '3') {
          logger.e('PedometerTrackingEngine: sensor unavailable (code 3). Stopping.', e, st);
          _controller.addError(
            SensorUnavailableException('pedometer', cause: e),
            st,
          );
          // Cancel the dead subscription — there is nothing to recover from.
          unawaited(_stepSub?.cancel());
          _stepSub = null;
          return;
        }
        // All other errors are potentially transient — log and keep listening.
        logger.e('PedometerTrackingEngine: step stream error (recoverable)', e, st);
        _controller.addError(e, st);
      },
      // CRITICAL: cancelOnError:false prevents Dart from silently closing the
      // subscription on the first error. We handle cancellation explicitly above.
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
