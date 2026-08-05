import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/running_sensor_availability.dart';

/// Keeps manual treadmill tracking alive when iOS suspends background work.
///
/// Location events are deliberately discarded and never contribute to running
/// metrics. Android does not require this keep-alive and uses a no-op path.
abstract interface class TreadmillBackgroundKeepAlive {
  Stream<TrackingEngineFailureException> get failures;

  Future<void> start();

  Future<void> stop();

  Future<void> dispose();
}

class LocationTreadmillBackgroundKeepAlive implements TreadmillBackgroundKeepAlive {
  LocationTreadmillBackgroundKeepAlive({
    RunningSensorAvailability? sensorAvailability,
    GeolocatorPlatform? geolocator,
    TargetPlatform? platform,
    Duration healthCheckInterval = RunningConstants.sensorHealthCheckInterval,
  }) : _platform = platform ?? defaultTargetPlatform,
       _sensorAvailability = sensorAvailability ?? RunningSensorAvailabilityService(platform: platform),
       _geolocator = geolocator ?? GeolocatorPlatform.instance,
       _healthCheckInterval = healthCheckInterval;

  final TargetPlatform _platform;
  final RunningSensorAvailability _sensorAvailability;
  final GeolocatorPlatform _geolocator;
  final Duration _healthCheckInterval;

  final _failureController = StreamController<TrackingEngineFailureException>.broadcast(sync: true);

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  Timer? _healthTimer;
  Future<void>? _healthCheckInFlight;
  Future<void>? _stopFuture;
  bool _isRunning = false;
  bool _isStopping = false;
  bool _terminalFailureSent = false;
  int _generation = 0;

  @override
  Stream<TrackingEngineFailureException> get failures => _failureController.stream;

  bool get _usesLocationKeepAlive {
    return _platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS;
  }

  @override
  Future<void> start() async {
    if (!_usesLocationKeepAlive || _isRunning) return;

    final stopping = _stopFuture;
    if (stopping != null) await stopping;

    final failure = await _sensorAvailability.treadmillFailure();
    if (failure != null) throw failure;

    _isRunning = true;
    _isStopping = false;
    _terminalFailureSent = false;
    final generation = ++_generation;

    try {
      final serviceStatusSubscription = _geolocator.getServiceStatusStream().listen(
        (status) {
          if (status == ServiceStatus.disabled) {
            _failOnce(
              const TrackingEngineFailureException(
                engine: TrackingEngineType.treadmill,
                dependency: TrackingDependency.location,
                reason: TrackingEngineFailureReason.locationServiceDisabled,
              ),
            );
          } else {
            unawaited(_runHealthCheck(generation));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(_classifyStreamError(error, stackTrace, generation));
        },
        onDone: () => _handleStreamDone(generation),
        cancelOnError: false,
      );
      if (!_isCurrentRun(generation)) {
        await serviceStatusSubscription.cancel();
        return;
      }
      _serviceStatusSubscription = serviceStatusSubscription;

      final positionSubscription = _geolocator
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
              unawaited(_classifyStreamError(error, stackTrace, generation));
            },
            onDone: () => _handleStreamDone(generation),
            cancelOnError: false,
          );
      if (!_isCurrentRun(generation)) {
        await positionSubscription.cancel();
        return;
      }
      _positionSubscription = positionSubscription;

      _healthTimer = Timer.periodic(
        _healthCheckInterval,
        (_) => unawaited(_runHealthCheck(generation)),
      );
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

  Future<void> _runHealthCheck(int generation) {
    final inFlight = _healthCheckInFlight;
    if (inFlight != null) return inFlight;

    final future = _runHealthCheckInternal(generation);
    _healthCheckInFlight = future;
    return future.whenComplete(() {
      if (identical(_healthCheckInFlight, future)) {
        _healthCheckInFlight = null;
      }
    });
  }

  Future<void> _runHealthCheckInternal(int generation) async {
    if (!_isCurrentRun(generation)) return;
    try {
      final failure = await _sensorAvailability.treadmillFailure();
      if (_isCurrentRun(generation) && failure != null) {
        _failOnce(failure);
      }
    } on Object catch (error, stackTrace) {
      logger.w(
        'TreadmillBackgroundKeepAlive: health check failed: $error',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _classifyStreamError(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) async {
    if (!_isCurrentRun(generation)) return;

    if (error is PermissionDeniedException) {
      _failOnce(
        TrackingEngineFailureException(
          engine: TrackingEngineType.treadmill,
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
          engine: TrackingEngineType.treadmill,
          dependency: TrackingDependency.location,
          reason: TrackingEngineFailureReason.locationServiceDisabled,
          cause: error,
        ),
        stackTrace,
      );
      return;
    }

    try {
      final failure = await _sensorAvailability.treadmillFailure();
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
        'TreadmillBackgroundKeepAlive: could not classify stream error: $healthError',
        healthError,
        healthStackTrace,
      );
    }

    logger.w(
      'TreadmillBackgroundKeepAlive: recoverable location stream error: $error',
      error,
      stackTrace,
    );
  }

  void _handleStreamDone(int generation) {
    if (!_isCurrentRun(generation) || _isStopping) return;
    _failOnce(
      const TrackingEngineFailureException(
        engine: TrackingEngineType.treadmill,
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
    logger.e(
      'TreadmillBackgroundKeepAlive: terminal failure',
      failure,
      stackTrace,
    );
    _failureController.add(failure);
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
    _isStopping = true;
    _isRunning = false;
    _generation++;
    _healthTimer?.cancel();
    _healthTimer = null;

    final positionCancellation = _positionSubscription?.cancel();
    final statusCancellation = _serviceStatusSubscription?.cancel();
    _positionSubscription = null;
    _serviceStatusSubscription = null;

    try {
      await Future.wait([
        ?positionCancellation,
        ?statusCancellation,
      ]);
    } finally {
      _isStopping = false;
      _terminalFailureSent = false;
    }
  }

  void _clearStopFuture(Future<void> future) {
    if (identical(_stopFuture, future)) _stopFuture = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _failureController.close();
  }
}
