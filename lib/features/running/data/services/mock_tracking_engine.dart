import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

@lazySingleton
class MockPedometerTrackingEngine implements TrackingEngine {
  static const double _strideMeters = 0.78;
  static const _tickInterval = Duration(seconds: 1);

  final _controller = StreamController<RunningMetrics>.broadcast();

  Timer? _tickTimer;
  int _lapSteps = 0;
  int _durationSeconds = 0;
  bool _isPaused = false;

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_tickTimer != null) return;
    _isPaused = false;

    if (initialOffset != null) {
      _durationSeconds = initialOffset.durationSeconds;
      _lapSteps = initialOffset.stepCount;
    } else {
      _durationSeconds = 0;
      _lapSteps = 0;
    }

    logger.d('MockPedometerTrackingEngine: starting mock tracking');

    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  @override
  void pause() {
    _isPaused = true;
    logger.d('MockPedometerTrackingEngine: paused');
  }

  @override
  void resume() {
    _isPaused = false;
    logger.d('MockPedometerTrackingEngine: resumed');
  }

  @override
  Future<void> stop() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    _isPaused = false;
    logger.d('MockPedometerTrackingEngine: stopped');
  }

  @override
  void reset() {
    _lapSteps = 0;
    _durationSeconds = 0;
    logger.d('MockPedometerTrackingEngine: metrics reset');
  }

  void _onTick() {
    if (_isPaused) return;

    _durationSeconds++;
    _lapSteps += 2; // Simulate 2 steps per second

    final distanceMeters = _lapSteps * _strideMeters;
    final distanceKm = distanceMeters / 1000;
    final durationHours = _durationSeconds / 3600;
    final avgSpeedKmH = durationHours > 0 ? (distanceKm / durationHours) : 0.0;
    final currentSpeedKmH = avgSpeedKmH; // Mock engine doesn't vary speed
    final avgPaceMinKm = avgSpeedKmH > 0 ? 60.0 / avgSpeedKmH : 0.0;
    final currentPaceMinKm = currentSpeedKmH > 0 ? 60.0 / currentSpeedKmH : 0.0;

    _controller.add(
      RunningMetrics(
        distanceMeters: distanceMeters,
        durationSeconds: _durationSeconds,
        avgSpeedKmH: avgSpeedKmH,
        currentSpeedKmH: currentSpeedKmH,
        avgPaceMinKm: avgPaceMinKm,
        currentPaceMinKm: currentPaceMinKm,
        stepCount: _lapSteps,
      ),
    );
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
