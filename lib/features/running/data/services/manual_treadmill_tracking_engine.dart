import 'dart:async';

import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/treadmill_background_keep_alive.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/adjustable_speed_tracking_engine.dart';
import 'package:reforge/features/running/domain/services/treadmill_speed_validation.dart';

typedef TreadmillTickStreamFactory = Stream<void> Function(Duration interval);

/// Manual treadmill engine driven by a user-configured speed.
///
/// Distance is integrated from canonical km/h and monotonic elapsed time. No
/// step or location event contributes to the metrics.
class ManualTreadmillTrackingEngine implements AdjustableSpeedTrackingEngine {
  ManualTreadmillTrackingEngine({
    TreadmillBackgroundKeepAlive? backgroundKeepAlive,
    TreadmillTickStreamFactory? tickStreamFactory,
    int Function()? nowMicroseconds,
  }) : _backgroundKeepAlive = backgroundKeepAlive ?? LocationTreadmillBackgroundKeepAlive(),
       _tickStreamFactory = tickStreamFactory ?? _defaultTickStream {
    if (nowMicroseconds != null) {
      _nowMicroseconds = nowMicroseconds;
    } else {
      final stopwatch = Stopwatch()..start();
      _nowMicroseconds = () => stopwatch.elapsedMicroseconds;
    }
  }

  static Stream<void> _defaultTickStream(Duration interval) {
    return Stream<void>.periodic(interval, (_) {});
  }

  final _controller = StreamController<RunningMetrics>.broadcast(sync: true);
  final TreadmillBackgroundKeepAlive _backgroundKeepAlive;
  final TreadmillTickStreamFactory _tickStreamFactory;
  late final int Function() _nowMicroseconds;

  StreamSubscription<void>? _tickSubscription;
  StreamSubscription<TrackingEngineFailureException>? _keepAliveFailureSubscription;
  Future<void>? _stopFuture;

  double _speedKmH = 0;
  double _distanceMeters = 0;
  double _activeSeconds = 0;
  int? _lastMeasurementMicroseconds;
  bool _hasConfiguredSpeed = false;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _terminalFailureSent = false;

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  void setSpeedKmH(double speedKmH) {
    TreadmillSpeedValidation.validate(speedKmH);

    if (_isRunning && !_isPaused && !_terminalFailureSent) {
      _accumulateUntil(_nowMicroseconds());
    }

    _speedKmH = speedKmH;
    _hasConfiguredSpeed = true;

    if (_isRunning && !_terminalFailureSent) {
      _emitMetrics();
    }
  }

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_isRunning) return;

    final stopping = _stopFuture;
    if (stopping != null) await stopping;

    if (!_hasConfiguredSpeed && TreadmillSpeedValidation.isValid(initialOffset?.currentSpeedKmH)) {
      _speedKmH = initialOffset!.currentSpeedKmH;
      _hasConfiguredSpeed = true;
    }
    TreadmillSpeedValidation.validate(_speedKmH);

    _distanceMeters = initialOffset?.distanceMeters ?? 0;
    _activeSeconds = (initialOffset?.durationSeconds ?? 0).toDouble();
    _isPaused = false;
    _terminalFailureSent = false;
    _isRunning = true;

    _keepAliveFailureSubscription = _backgroundKeepAlive.failures.listen(
      _failOnce,
    );

    try {
      await _backgroundKeepAlive.start();
      if (!_isRunning || _terminalFailureSent) {
        final stopping = _stopFuture;
        if (stopping != null) await stopping;
        return;
      }

      _lastMeasurementMicroseconds = _nowMicroseconds();
      final tickSubscription = _tickStreamFactory(RunningConstants.engineTickInterval).listen(
        (_) => _onTick(),
        onError: (Object error, StackTrace stackTrace) {
          _failOnce(
            TrackingEngineFailureException(
              engine: TrackingEngineType.treadmill,
              dependency: TrackingDependency.clock,
              reason: TrackingEngineFailureReason.unrecoverableStreamFailure,
              cause: error,
            ),
            stackTrace,
          );
        },
        onDone: () {
          if (_isRunning) {
            _failOnce(
              const TrackingEngineFailureException(
                engine: TrackingEngineType.treadmill,
                dependency: TrackingDependency.clock,
                reason: TrackingEngineFailureReason.streamClosed,
              ),
            );
          }
        },
        cancelOnError: false,
      );
      if (!_isRunning || _terminalFailureSent) {
        await tickSubscription.cancel();
        return;
      }
      _tickSubscription = tickSubscription;
      _emitMetrics();
      logger.d('ManualTreadmillTrackingEngine: started');
    } on Object catch (error) {
      await stop();
      if (error is TrackingEngineFailureException) rethrow;
      throw TrackingEngineFailureException(
        engine: TrackingEngineType.treadmill,
        dependency: TrackingDependency.location,
        reason: TrackingEngineFailureReason.unrecoverableStreamFailure,
        cause: error,
      );
    }
  }

  void _onTick() {
    if (!_isRunning || _isPaused || _terminalFailureSent) return;
    _accumulateUntil(_nowMicroseconds());
    _emitMetrics();
  }

  void _accumulateUntil(int nowMicroseconds) {
    final previousMicroseconds = _lastMeasurementMicroseconds;
    _lastMeasurementMicroseconds = nowMicroseconds;
    if (previousMicroseconds == null) return;

    final elapsedMicroseconds = nowMicroseconds - previousMicroseconds;
    if (elapsedMicroseconds <= 0) return;

    final elapsedSeconds = elapsedMicroseconds / Duration.microsecondsPerSecond;
    _distanceMeters += _speedKmH / 3.6 * elapsedSeconds;
    _activeSeconds += elapsedSeconds;
  }

  @override
  void pause() {
    if (!_isRunning || _isPaused || _terminalFailureSent) return;
    _accumulateUntil(_nowMicroseconds());
    _isPaused = true;
    _lastMeasurementMicroseconds = null;
    _emitMetrics();
    logger.d('ManualTreadmillTrackingEngine: paused');
  }

  @override
  void resume() {
    if (!_isRunning || !_isPaused || _terminalFailureSent) return;
    _isPaused = false;
    _lastMeasurementMicroseconds = _nowMicroseconds();
    _emitMetrics();
    logger.d('ManualTreadmillTrackingEngine: resumed');
  }

  @override
  void reset() {
    if (_isRunning && !_isPaused && !_terminalFailureSent) {
      _accumulateUntil(_nowMicroseconds());
    }
    _distanceMeters = 0;
    _activeSeconds = 0;
    _lastMeasurementMicroseconds = _isRunning && !_isPaused ? _nowMicroseconds() : null;
    logger.d('ManualTreadmillTrackingEngine: metrics reset');
  }

  RunningMetrics get _metrics {
    final avgSpeedKmH = _activeSeconds > 0 ? _distanceMeters / _activeSeconds * 3.6 : 0.0;

    return RunningMetrics(
      distanceMeters: _distanceMeters,
      durationSeconds: _activeSeconds.floor(),
      avgSpeedKmH: avgSpeedKmH,
      currentSpeedKmH: _speedKmH,
      avgPaceMinKm: avgSpeedKmH > 0 ? 60 / avgSpeedKmH : 0,
      currentPaceMinKm: _speedKmH > 0 ? 60 / _speedKmH : 0,
      stepCount: 0,
    );
  }

  void _emitMetrics() {
    if (!_controller.isClosed) {
      _controller.add(_metrics);
    }
  }

  void _failOnce(
    TrackingEngineFailureException failure, [
    StackTrace? stackTrace,
  ]) {
    if (!_isRunning || _terminalFailureSent) return;
    _terminalFailureSent = true;
    logger.e(
      'ManualTreadmillTrackingEngine: terminal failure',
      failure,
      stackTrace,
    );
    _controller.addError(failure, stackTrace ?? StackTrace.current);
    unawaited(stop());
  }

  @override
  Future<void> stop() {
    final inFlight = _stopFuture;
    if (inFlight != null) return inFlight;

    final future = _stopInternal();
    _stopFuture = future;
    unawaited(
      future.then<void>(
        (_) => _clearStopFuture(future),
        onError: (Object _, StackTrace _) => _clearStopFuture(future),
      ),
    );
    return future;
  }

  Future<void> _stopInternal() async {
    if (_isRunning && !_isPaused) {
      _accumulateUntil(_nowMicroseconds());
      if (!_terminalFailureSent) _emitMetrics();
    }
    _isRunning = false;
    _lastMeasurementMicroseconds = null;

    final tickCancellation = _tickSubscription?.cancel();
    final failureCancellation = _keepAliveFailureSubscription?.cancel();
    _tickSubscription = null;
    _keepAliveFailureSubscription = null;

    try {
      await Future.wait([
        ?tickCancellation,
        ?failureCancellation,
      ]);
      await _backgroundKeepAlive.stop();
    } finally {
      _isPaused = false;
      _terminalFailureSent = false;
      _speedKmH = 0;
      _hasConfiguredSpeed = false;
      logger.d('ManualTreadmillTrackingEngine: stopped');
    }
  }

  void _clearStopFuture(Future<void> future) {
    if (identical(_stopFuture, future)) _stopFuture = null;
  }

  Future<void> dispose() async {
    await stop();
    await _backgroundKeepAlive.dispose();
    await _controller.close();
  }
}
