import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// Pedometer-based [TrackingEngine] for treadmill workouts.
///
/// Registered as the default [TrackingEngine] in the DI container.
class PedometerTrackingEngine implements TrackingEngine {
  /// Ticker interval — we derive duration from a wall-clock stopwatch rather
  /// than relying on the pedometer timestamp, which varies per device.
  static const Duration _tickInterval = RunningConstants.engineTickInterval;

  static const double _tau = 3; // EMA time constant in seconds
  static const int _stallTimeoutMs = 2500;

  // ── State ──────────────────────────────────────────────────────────────────

  final _controller = StreamController<RunningMetrics>.broadcast();

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;
  StreamSubscription<Position>? _iosKeepAliveSub;
  Timer? _tickTimer;

  int _baselineStepCount = 0; // platform step counter at the moment tracking started
  int _lapSteps = 0; // steps accumulated in this lap
  int _durationSeconds = 0; // elapsed seconds in this lap
  bool _isPaused = false;

  double _distanceMeters = 0;
  int _lastStepMs = 0;
  int _prevSteps = 0;
  double _emaSpeed = 0;

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_tickTimer != null) return; // Already tracking — ignore.

    _isPaused = false;

    if (initialOffset != null) {
      _durationSeconds = initialOffset.durationSeconds;
      _lapSteps = initialOffset.stepCount;
      _distanceMeters = initialOffset.distanceMeters;
      _prevSteps = initialOffset.stepCount;
    } else {
      _durationSeconds = 0;
      _lapSteps = 0;
      _distanceMeters = 0.0;
      _prevSteps = 0;
    }
    _baselineStepCount = 0;
    _lastStepMs = 0;
    _emaSpeed = 0.0;

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

    // Subscribe to pedestrian status to instantly snap speed to 0 when stopped
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (status) {
        if (status.status == 'stopped') {
          _emaSpeed = 0.0;
        }
      },
      onError: (_) {
        // Ignored. Fallback to EMA decay if stream is unavailable.
      },
      cancelOnError: false,
    );

    // Wall-clock tick to increment duration and emit metrics every second.
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());

    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      _iosKeepAliveSub = Geolocator.getPositionStream(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.lowest,
          distanceFilter: 100,
          activityType: ActivityType.fitness,
          showBackgroundLocationIndicator: true,
        ),
      ).listen((_) {});
    }
  }

  @override
  void pause() {
    _isPaused = true;
    logger.d('PedometerTrackingEngine: paused');
  }

  @override
  void resume() {
    _isPaused = false;
    _lastStepMs = 0;
    logger.d('PedometerTrackingEngine: resumed');
  }

  @override
  void stop() {
    unawaited(_stepSub?.cancel());
    _stepSub = null;
    unawaited(_statusSub?.cancel());
    _statusSub = null;
    unawaited(_iosKeepAliveSub?.cancel());
    _iosKeepAliveSub = null;
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
    _distanceMeters = 0.0;
    _lastStepMs = 0;
    _prevSteps = 0;
    _emaSpeed = 0.0;
    logger.d('PedometerTrackingEngine: metrics reset');
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _onStep(StepCount event) {
    if (_isPaused) return;

    if (_baselineStepCount == 0) {
      _baselineStepCount = event.steps;
    }

    _lapSteps = event.steps - _baselineStepCount;

    final nowMs = event.timeStamp.millisecondsSinceEpoch;
    final stepsInEvent = _lapSteps - _prevSteps;

    if (_lastStepMs > 0 && stepsInEvent > 0) {
      final avgIntervalMs = (nowMs - _lastStepMs) / stepsInEvent;

      // Guard: duplicate/zero timestamps (batched Android events) must not
      // reach the division below, or _emaSpeed will latch on Infinity forever.
      if (avgIntervalMs <= 0) {
        _prevSteps = _lapSteps;
        _lastStepMs = nowMs;
        return;
      }

      final cadencePerMin = 60000.0 / avgIntervalMs;
      final strideM = (0.78 + (cadencePerMin - 160) * 0.0028).clamp(0.55, 1.10);

      _distanceMeters += strideM * stepsInEvent;

      final instantSpeedKmH = (strideM / (avgIntervalMs / 1000.0)) * 3.6;

      // dt-aware alpha (see fix #3 below) instead of the fixed dt=1 constant.
      final dtSec = avgIntervalMs / 1000.0;
      final alpha = dtSec / (_tau + dtSec);

      _emaSpeed = alpha * instantSpeedKmH + (1.0 - alpha) * _emaSpeed;
    } else if (stepsInEvent > 0) {
      _distanceMeters += 0.78 * stepsInEvent;
    }

    _lastStepMs = nowMs;
    _prevSteps = _lapSteps;
  }

  void _onTick() {
    if (_isPaused) return;

    _durationSeconds++;

    if (_lastStepMs > 0 && DateTime.now().millisecondsSinceEpoch - _lastStepMs > _stallTimeoutMs) {
      _emaSpeed = 0.0;
    }

    final distanceKm = _distanceMeters / 1000.0;
    final durationHours = _durationSeconds / 3600.0;
    final avgSpeedKmH = (durationHours > 0) ? (distanceKm / durationHours) : 0.0;

    final avgPaceMinKm = avgSpeedKmH > 0 ? 60.0 / avgSpeedKmH : 0.0;
    final currentPaceMinKm = _emaSpeed > 0 ? 60.0 / _emaSpeed : 0.0;

    _controller.add(
      RunningMetrics(
        distanceMeters: _distanceMeters,
        durationSeconds: _durationSeconds,
        avgSpeedKmH: avgSpeedKmH,
        currentSpeedKmH: _emaSpeed,
        avgPaceMinKm: avgPaceMinKm,
        currentPaceMinKm: currentPaceMinKm,
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
