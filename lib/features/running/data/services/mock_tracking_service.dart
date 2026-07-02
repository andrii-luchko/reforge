import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';

import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/services/running_tracking_service.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';

@lazySingleton
class MockPedometerTrackingService implements RunningTrackingService {
  static const double _strideMeters = 0.78;
  static const _tickInterval = Duration(seconds: 1);

  final _controller = StreamController<RunningMetrics>.broadcast();
  Timer? _tickTimer;

  int _lapSteps = 0;
  int _durationSeconds = 0;
  bool _isPaused = false;
  RunningMode? _mode;

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
    if (_mode != null) return;
    _mode = mode;
    _isPaused = false;

    if (initialOffset != null) {
      _durationSeconds = initialOffset.durationSeconds;
      _lapSteps = initialOffset.stepCount;
    } else {
      _durationSeconds = 0;
      _lapSteps = 0;
    }

    logger.d('MockPedometerTrackingService: starting mock tracking');

    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  @override
  void pauseTracking() {
    _isPaused = true;
    logger.d('MockPedometerTrackingService: paused');
  }

  @override
  void resumeTracking() {
    _isPaused = false;
    logger.d('MockPedometerTrackingService: resumed');
  }

  @override
  void forceNextLap() {}

  @override
  void stopTracking() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _mode = null;
    _isPaused = false;
    logger.d('MockPedometerTrackingService: stopped');
  }

  @override
  void resetMetrics() {
    _lapSteps = 0;
    _durationSeconds = 0;
    logger.d('MockPedometerTrackingService: metrics reset');
  }

  void _onTick() {
    if (_isPaused) return;

    _durationSeconds++;
    _lapSteps += 2;

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

  void dispose() {
    stopTracking();
    unawaited(_controller.close());
  }
}
