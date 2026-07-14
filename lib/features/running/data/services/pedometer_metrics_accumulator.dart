import 'package:reforge/features/running/domain/entities/running_metrics.dart';

/// Converts the device's absolute step counter into metrics for one lap.
///
/// The OS counter is shared across the device lifetime, while this class keeps
/// only the steps earned during the active lap. It continues to observe raw
/// events while paused so that paused walking is never counted after resume.
class PedometerMetricsAccumulator {
  static const double _defaultStrideMeters = 0.78;
  static const double _minStrideMeters = 0.55;
  static const double _maxStrideMeters = 1.10;
  static const double _minCadencePerMinute = 60;
  static const double _maxCadencePerMinute = 240;
  static const double _maxSpeedKmH = 25;
  static const double _emaTimeConstantSeconds = 3;

  int? _lastRawStepCount;
  int? _lastActiveStepMs;
  int _trackedSteps = 0;
  int _durationSeconds = 0;
  double _distanceMeters = 0;
  double _emaSpeedKmH = 0;
  bool _isPaused = false;
  bool _receivedRawStepWhilePaused = false;
  bool _discardFirstDeltaAfterResume = false;

  void start({RunningMetrics? initialOffset}) {
    _trackedSteps = initialOffset?.stepCount ?? 0;
    _durationSeconds = initialOffset?.durationSeconds ?? 0;
    _distanceMeters = initialOffset?.distanceMeters ?? 0;
    _lastRawStepCount = null;
    _lastActiveStepMs = null;
    _emaSpeedKmH = 0;
    _isPaused = false;
    _receivedRawStepWhilePaused = false;
    _discardFirstDeltaAfterResume = false;
  }

  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _receivedRawStepWhilePaused = false;
    _lastActiveStepMs = null;
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _discardFirstDeltaAfterResume = !_receivedRawStepWhilePaused;
    _lastActiveStepMs = null;
  }

  void markStopped() {
    _emaSpeedKmH = 0;
  }

  void recordRawStep({required int rawStepCount, required int timestampMs}) {
    final previousRawStepCount = _lastRawStepCount;
    _lastRawStepCount = rawStepCount;

    if (_isPaused) {
      _receivedRawStepWhilePaused = true;
      return;
    }

    if (previousRawStepCount == null) return;

    final rawDelta = rawStepCount - previousRawStepCount;
    if (rawDelta <= 0) {
      // The counter can reset after a reboot or report a duplicate batch.
      _lastActiveStepMs = null;
      _emaSpeedKmH = 0;
      return;
    }

    if (_discardFirstDeltaAfterResume) {
      // No events arrived while paused, so this batch may include paused
      // walking. Dropping it avoids awarding the paused movement to the lap.
      _discardFirstDeltaAfterResume = false;
      return;
    }

    _trackedSteps += rawDelta;
    final previousActiveStepMs = _lastActiveStepMs;
    _lastActiveStepMs = timestampMs;

    if (previousActiveStepMs == null) {
      _distanceMeters += _defaultStrideMeters * rawDelta;
      return;
    }

    final intervalMs = (timestampMs - previousActiveStepMs) / rawDelta;
    if (intervalMs <= 0) {
      _distanceMeters += _defaultStrideMeters * rawDelta;
      return;
    }

    final cadence = (60000 / intervalMs).clamp(
      _minCadencePerMinute,
      _maxCadencePerMinute,
    );
    final strideMeters = (_defaultStrideMeters + (cadence - 160) * 0.0028).clamp(_minStrideMeters, _maxStrideMeters);
    _distanceMeters += strideMeters * rawDelta;

    final instantSpeedKmH = (strideMeters * cadence / 60 * 3.6).clamp(
      0,
      _maxSpeedKmH,
    );
    final intervalSeconds = intervalMs / 1000;
    final alpha = intervalSeconds / (_emaTimeConstantSeconds + intervalSeconds);
    _emaSpeedKmH = alpha * instantSpeedKmH + (1 - alpha) * _emaSpeedKmH;
  }

  void tick({required int nowMs, required int stallTimeoutMs}) {
    if (_isPaused) return;
    _durationSeconds++;
    final lastActiveStepMs = _lastActiveStepMs;
    if (lastActiveStepMs != null && nowMs - lastActiveStepMs > stallTimeoutMs) {
      _emaSpeedKmH = 0;
    }
  }

  RunningMetrics get metrics {
    final distanceKm = _distanceMeters / 1000;
    final durationHours = _durationSeconds / 3600;
    final avgSpeedKmH = durationHours > 0 ? distanceKm / durationHours : 0.0;
    final avgPaceMinKm = avgSpeedKmH > 0 ? 60 / avgSpeedKmH : 0.0;
    final currentPaceMinKm = _emaSpeedKmH > 0 ? 60 / _emaSpeedKmH : 0.0;

    return RunningMetrics(
      distanceMeters: _distanceMeters,
      durationSeconds: _durationSeconds,
      avgSpeedKmH: avgSpeedKmH,
      currentSpeedKmH: _emaSpeedKmH,
      avgPaceMinKm: avgPaceMinKm,
      currentPaceMinKm: currentPaceMinKm,
      stepCount: _trackedSteps,
    );
  }
}
