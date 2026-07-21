import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/pedometer_metrics_accumulator.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/running_sensor_availability.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// Pedometer-based [TrackingEngine] for treadmill workouts.
///
/// Registered as the default [TrackingEngine] in the DI container.
class PedometerTrackingEngine implements TrackingEngine {
  PedometerTrackingEngine({
    RunningSensorAvailability? sensorAvailability,
    GeolocatorPlatform? geolocator,
    TargetPlatform? platform,
    Stream<StepCount> Function()? stepCountStream,
    Stream<PedestrianStatus> Function()? pedestrianStatusStream,
    Duration healthCheckInterval = RunningConstants.sensorHealthCheckInterval,
  }) : _platform = platform ?? defaultTargetPlatform,
       _sensorAvailability = sensorAvailability ?? RunningSensorAvailabilityService(platform: platform),
       _geolocator = geolocator ?? GeolocatorPlatform.instance,
       _stepCountStream = stepCountStream ?? (() => Pedometer.stepCountStream),
       _pedestrianStatusStream = pedestrianStatusStream ?? (() => Pedometer.pedestrianStatusStream),
       _healthCheckInterval = healthCheckInterval;

  /// Ticker interval — we derive duration from a wall-clock stopwatch rather
  /// than relying on the pedometer timestamp, which varies per device.
  static const Duration _tickInterval = RunningConstants.engineTickInterval;

  static const int _stallTimeoutMs = 2500;

  // ── State ──────────────────────────────────────────────────────────────────

  final _controller = StreamController<RunningMetrics>.broadcast();
  final TargetPlatform _platform;
  final RunningSensorAvailability _sensorAvailability;
  final GeolocatorPlatform _geolocator;
  final Stream<StepCount> Function() _stepCountStream;
  final Stream<PedestrianStatus> Function() _pedestrianStatusStream;
  final Duration _healthCheckInterval;

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;
  StreamSubscription<Position>? _iosKeepAliveSub;
  StreamSubscription<ServiceStatus>? _locationServiceSub;
  Timer? _tickTimer;
  Timer? _healthTimer;
  Future<void>? _healthCheckInFlight;
  Future<void>? _stopFuture;

  bool _isPaused = false;
  bool _isRunning = false;
  bool _isStopping = false;
  bool _terminalFailureSent = false;
  int _generation = 0;
  final _metricsAccumulator = PedometerMetricsAccumulator();

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_isRunning) return;
    final stopping = _stopFuture;
    if (stopping != null) await stopping;

    final failure = await _checkAvailabilityForStart();
    if (failure != null) throw failure;

    _isPaused = false;
    _isStopping = false;
    _terminalFailureSent = false;
    _isRunning = true;
    final generation = ++_generation;

    _metricsAccumulator.start(initialOffset: initialOffset);

    logger.d('PedometerTrackingEngine: starting');

    try {
      // Subscribe to the device step counter.
      _stepSub = _stepCountStream().listen(
        _onStep,
        onError: (Object error, StackTrace stackTrace) {
          unawaited(_handleStepError(error, stackTrace, generation));
        },
        onDone: () => _handleStepStreamDone(generation),
        cancelOnError: false,
      );

      // Pedestrian status is optional; EMA decay remains the fallback.
      _statusSub = _pedestrianStatusStream().listen(
        (status) {
          if (status.status == 'stopped') {
            _metricsAccumulator.markStopped();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.w('PedometerTrackingEngine: pedestrian status unavailable: $error');
        },
        cancelOnError: false,
      );

      // Wall-clock tick to increment duration and emit metrics every second.
      _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
      _healthTimer = Timer.periodic(
        _healthCheckInterval,
        (_) => unawaited(_runHealthCheck(generation)),
      );

      if (_usesIosLocationKeepAlive) {
        _locationServiceSub = _geolocator.getServiceStatusStream().listen(
          (status) {
            if (status == ServiceStatus.disabled) {
              _failOnce(
                const TrackingEngineFailureException(
                  engine: TrackingEngineType.pedometer,
                  dependency: TrackingDependency.location,
                  reason: TrackingEngineFailureReason.locationServiceDisabled,
                ),
              );
            } else {
              unawaited(_runHealthCheck(generation));
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.w('PedometerTrackingEngine: location service status unavailable: $error');
          },
          cancelOnError: false,
        );
        _iosKeepAliveSub = _geolocator
            .getPositionStream(
              locationSettings: AppleSettings(
                accuracy: LocationAccuracy.lowest,
                distanceFilter: 100,
                activityType: ActivityType.fitness,
                showBackgroundLocationIndicator: true,
              ),
            )
            .listen(
              (_) {},
              onError: (Object error, StackTrace stackTrace) {
                unawaited(_handleKeepAliveError(error, stackTrace, generation));
              },
              onDone: () => _handleKeepAliveDone(generation),
              cancelOnError: false,
            );
      }
    } on Object catch (error) {
      await stop();
      if (error is TrackingEngineFailureException) rethrow;
      throw TrackingEngineFailureException(
        engine: TrackingEngineType.pedometer,
        dependency: TrackingDependency.motion,
        reason: TrackingEngineFailureReason.unrecoverableStreamFailure,
        cause: error,
      );
    }
  }

  @override
  void pause() {
    if (!_isRunning || _terminalFailureSent) return;
    _isPaused = true;
    _metricsAccumulator.pause();
    logger.d('PedometerTrackingEngine: paused');
  }

  @override
  void resume() {
    if (!_isRunning || _terminalFailureSent) return;
    _isPaused = false;
    _metricsAccumulator.resume();
    logger.d('PedometerTrackingEngine: resumed');
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
    _isStopping = true;
    _isRunning = false;
    _generation++;
    _tickTimer?.cancel();
    _tickTimer = null;
    _healthTimer?.cancel();
    _healthTimer = null;

    final stepCancellation = _stepSub?.cancel();
    final statusCancellation = _statusSub?.cancel();
    final iosKeepAliveCancellation = _iosKeepAliveSub?.cancel();
    final locationServiceCancellation = _locationServiceSub?.cancel();

    _stepSub = null;
    _statusSub = null;
    _iosKeepAliveSub = null;
    _locationServiceSub = null;

    try {
      await Future.wait([
        ?stepCancellation,
        ?statusCancellation,
        ?iosKeepAliveCancellation,
        ?locationServiceCancellation,
      ]);
    } finally {
      _isPaused = false;
      _isStopping = false;
      logger.d('PedometerTrackingEngine: stopped');
    }
  }

  @override
  void reset() {
    _metricsAccumulator.start();
    logger.d('PedometerTrackingEngine: metrics reset');
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _onStep(StepCount event) {
    if (!_isRunning || _terminalFailureSent) return;
    _metricsAccumulator.recordRawStep(
      rawStepCount: event.steps,
      timestampMs: event.timeStamp.millisecondsSinceEpoch,
    );
  }

  void _onTick() {
    if (!_isRunning || _terminalFailureSent || _isPaused) return;

    _metricsAccumulator.tick(
      nowMs: DateTime.now().millisecondsSinceEpoch,
      stallTimeoutMs: _stallTimeoutMs,
    );
    _controller.add(_metricsAccumulator.metrics);
  }

  /// Dispose when the singleton is torn down (e.g. during testing).
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  bool get _usesIosLocationKeepAlive {
    return _platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS;
  }

  Future<TrackingEngineFailureException?> _checkAvailabilityForStart() async {
    try {
      return await _sensorAvailability.pedometerFailure();
    } on Object catch (error) {
      return TrackingEngineFailureException(
        engine: TrackingEngineType.pedometer,
        dependency: TrackingDependency.motion,
        reason: TrackingEngineFailureReason.unrecoverableStreamFailure,
        cause: error,
      );
    }
  }

  Future<void> _runHealthCheck(int generation) {
    final inFlight = _healthCheckInFlight;
    if (inFlight != null) return inFlight;

    final future = _runHealthCheckInternal(generation);
    _healthCheckInFlight = future;
    return future.whenComplete(() {
      if (identical(_healthCheckInFlight, future)) _healthCheckInFlight = null;
    });
  }

  Future<void> _runHealthCheckInternal(int generation) async {
    if (!_isCurrentRun(generation)) return;
    try {
      final failure = await _sensorAvailability.pedometerFailure();
      if (_isCurrentRun(generation) && failure != null) {
        _failOnce(failure);
      }
    } on Object catch (error, stackTrace) {
      logger.w('PedometerTrackingEngine: health check failed: $error', error, stackTrace);
    }
  }

  Future<void> _handleStepError(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) async {
    if (!_isCurrentRun(generation)) return;
    logger.e('PedometerTrackingEngine: step stream error', error, stackTrace);

    if (error is PlatformException) {
      _failOnce(
        TrackingEngineFailureException(
          engine: TrackingEngineType.pedometer,
          dependency: TrackingDependency.motion,
          reason: TrackingEngineFailureReason.sensorUnavailable,
          cause: error,
        ),
        stackTrace,
      );
      return;
    }

    await _classifyOrReportRecoverable(error, stackTrace, generation);
  }

  Future<void> _handleKeepAliveError(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) async {
    if (!_isCurrentRun(generation)) return;
    logger.e('PedometerTrackingEngine: iOS location keep-alive error', error, stackTrace);

    if (error is PermissionDeniedException) {
      _failOnce(
        TrackingEngineFailureException(
          engine: TrackingEngineType.pedometer,
          dependency: TrackingDependency.location,
          reason: TrackingEngineFailureReason.locationPermissionDenied,
          cause: error,
        ),
        stackTrace,
      );
      return;
    }
    if (error is LocationServiceDisabledException) {
      _failOnce(
        TrackingEngineFailureException(
          engine: TrackingEngineType.pedometer,
          dependency: TrackingDependency.location,
          reason: TrackingEngineFailureReason.locationServiceDisabled,
          cause: error,
        ),
        stackTrace,
      );
      return;
    }

    await _classifyOrReportRecoverable(error, stackTrace, generation);
  }

  Future<void> _classifyOrReportRecoverable(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) async {
    try {
      final failure = await _sensorAvailability.pedometerFailure();
      if (!_isCurrentRun(generation)) return;
      if (failure != null) {
        _failOnce(
          TrackingEngineFailureException(
            engine: failure.engine,
            dependency: failure.dependency,
            reason: failure.reason,
            cause: error,
          ),
          stackTrace,
        );
        return;
      }
    } on Object catch (healthError, healthStackTrace) {
      logger.w(
        'PedometerTrackingEngine: could not classify stream error: $healthError',
        healthError,
        healthStackTrace,
      );
    }

    if (_isCurrentRun(generation)) {
      _controller.addError(
        SensorStreamException('pedometer', cause: error),
        stackTrace,
      );
    }
  }

  void _handleStepStreamDone(int generation) {
    if (!_isCurrentRun(generation) || _isStopping) return;
    _failOnce(
      const TrackingEngineFailureException(
        engine: TrackingEngineType.pedometer,
        dependency: TrackingDependency.motion,
        reason: TrackingEngineFailureReason.streamClosed,
      ),
    );
  }

  void _handleKeepAliveDone(int generation) {
    if (!_isCurrentRun(generation) || _isStopping) return;
    _failOnce(
      const TrackingEngineFailureException(
        engine: TrackingEngineType.pedometer,
        dependency: TrackingDependency.location,
        reason: TrackingEngineFailureReason.streamClosed,
      ),
    );
  }

  bool _isCurrentRun(int generation) {
    return _isRunning && !_terminalFailureSent && generation == _generation;
  }

  void _failOnce(
    TrackingEngineFailureException failure, [
    StackTrace? stackTrace,
  ]) {
    if (!_isRunning || _terminalFailureSent) return;
    _terminalFailureSent = true;
    logger.e('PedometerTrackingEngine: terminal failure', failure, stackTrace);
    _controller.addError(failure, stackTrace ?? StackTrace.current);
    unawaited(stop());
  }

  void _clearStopFuture(Future<void> future) {
    if (identical(_stopFuture, future)) _stopFuture = null;
  }
}
