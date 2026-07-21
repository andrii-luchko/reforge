import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/kalman_location_filter.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/running_sensor_availability.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

class GpsTrackingEngine implements TrackingEngine {
  GpsTrackingEngine({
    RunningSensorAvailability? sensorAvailability,
    GeolocatorPlatform? geolocator,
    Duration healthCheckInterval = RunningConstants.sensorHealthCheckInterval,
  }) : _sensorAvailability = sensorAvailability ?? RunningSensorAvailabilityService(),
       _geolocator = geolocator ?? GeolocatorPlatform.instance,
       _healthCheckInterval = healthCheckInterval;

  final _controller = StreamController<RunningMetrics>.broadcast();
  final RunningSensorAvailability _sensorAvailability;
  final GeolocatorPlatform _geolocator;
  final Duration _healthCheckInterval;

  Timer? _ticker;
  Timer? _healthTimer;
  // ignore: cancel_subscriptions, canceled by the idempotent stop/dispose path
  StreamSubscription<Position>? _positionSub;
  // ignore: cancel_subscriptions, canceled by the idempotent stop/dispose path
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  Future<void>? _healthCheckInFlight;
  Future<void>? _stopFuture;

  double _totalDistance = 0;
  int _durationSec = 0;
  int _lastProcessedMs = 0; // wall-clock time of the last successful Kalman update
  static const int _gpsStallTimeoutMs = 5000;
  RouteCoordinate? _lastSmoothedPoint;
  RouteCoordinate? _lastAcceptedRawPoint;
  int? _lastAcceptedTimestampMs;
  bool _isPaused = false;
  bool _isRunning = false;
  bool _isStopping = false;
  bool _terminalFailureSent = false;
  int _generation = 0;
  bool _hasLoggedFirstTick = false;
  bool _hasLoggedFirstPosition = false;

  final _kalmanFilter = KalmanLocationFilter();

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_isRunning) return;
    final stopping = _stopFuture;
    if (stopping != null) await stopping;

    final failure = await _checkAvailabilityForStart();
    if (failure != null) throw failure;

    logger.d(
      '[GpsTrackingEngine][${DateTime.now().toIso8601String()}] start '
      'initialDuration=${initialOffset?.durationSeconds ?? 0}',
    );
    _totalDistance = initialOffset?.distanceMeters ?? 0;
    _durationSec = initialOffset?.durationSeconds ?? 0;

    _isPaused = false;
    _lastSmoothedPoint = null;
    _lastAcceptedRawPoint = null;
    _lastAcceptedTimestampMs = null;
    _lastProcessedMs = 0;
    _hasLoggedFirstTick = false;
    _hasLoggedFirstPosition = false;
    _kalmanFilter.reset();
    _terminalFailureSent = false;
    _isStopping = false;
    _isRunning = true;
    final generation = ++_generation;

    try {
      _serviceStatusSub = _geolocator.getServiceStatusStream().listen(
        (status) {
          if (status == ServiceStatus.disabled) {
            _failOnce(
              const TrackingEngineFailureException(
                engine: TrackingEngineType.gps,
                dependency: TrackingDependency.location,
                reason: TrackingEngineFailureReason.locationServiceDisabled,
              ),
            );
          } else {
            unawaited(_runHealthCheck(generation));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.w('GpsTrackingEngine: location service status stream error: $error', error, stackTrace);
        },
        cancelOnError: false,
      );

      _positionSub = _geolocator
          .getPositionStream(locationSettings: _getFitnessLocationSettings())
          .listen(
            (pos) {
              if (!_isRunning || _terminalFailureSent || _isPaused) return;

              if (!_hasLoggedFirstPosition) {
                _hasLoggedFirstPosition = true;
                logger.d(
                  '[GpsTrackingEngine][${DateTime.now().toIso8601String()}] '
                  'first_position accuracy=${pos.accuracy}',
                );
              }

              if (pos.accuracy > RunningConstants.maxGpsAccuracyMeters) {
                return;
              }

              final timestampMs = pos.timestamp.millisecondsSinceEpoch;
              if (_isImplausibleRawJump(pos, timestampMs)) return;

              // Process the raw point through Kalman Filter
              final updateResult = _kalmanFilter.process(
                lat: pos.latitude,
                lng: pos.longitude,
                accuracy: pos.accuracy,
                timestampMs: timestampMs,
              );

              if (updateResult == KalmanUpdateResult.ignoredStale ||
                  updateResult == KalmanUpdateResult.rejectedOutlier) {
                return;
              }

              _lastProcessedMs = DateTime.now().millisecondsSinceEpoch;

              final smoothedLat = _kalmanFilter.latitude;
              final smoothedLng = _kalmanFilter.longitude;
              final smoothedHeading = _kalmanFilter.heading;

              if (updateResult == KalmanUpdateResult.initialized || _lastSmoothedPoint == null) {
                _lastSmoothedPoint = RouteCoordinate(
                  latitude: smoothedLat,
                  longitude: smoothedLng,
                  heading: smoothedHeading,
                );
                _lastAcceptedRawPoint = RouteCoordinate(
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                );
                _lastAcceptedTimestampMs = timestampMs;
                return;
              }

              final distanceDelta = _geolocator.distanceBetween(
                _lastSmoothedPoint!.latitude,
                _lastSmoothedPoint!.longitude,
                smoothedLat,
                smoothedLng,
              );

              if (distanceDelta > RunningConstants.gpsDistanceFilterMeters) {
                _totalDistance += distanceDelta;
                _lastSmoothedPoint = RouteCoordinate(
                  latitude: smoothedLat,
                  longitude: smoothedLng,
                  heading: smoothedHeading,
                );

                // Emit immediately to make the map and metrics feel responsive
                // _emitMetrics();
              }

              _lastAcceptedRawPoint = RouteCoordinate(
                latitude: pos.latitude,
                longitude: pos.longitude,
              );
              _lastAcceptedTimestampMs = timestampMs;
            },
            onError: (Object error, StackTrace stackTrace) {
              unawaited(_handlePositionError(error, stackTrace, generation));
            },
            onDone: () => _handleUnexpectedStreamDone(generation),
            // Temporary Core Location failures do not close the native stream.
            cancelOnError: false,
          );

      _ticker = Timer.periodic(RunningConstants.engineTickInterval, (_) {
        if (!_isRunning || _terminalFailureSent || _isPaused) return;
        if (!_hasLoggedFirstTick) {
          _hasLoggedFirstTick = true;
          logger.d('[GpsTrackingEngine][${DateTime.now().toIso8601String()}] first_tick');
        }
        _durationSec++;
        _emitMetrics();
      });
      _healthTimer = Timer.periodic(
        _healthCheckInterval,
        (_) => unawaited(_runHealthCheck(generation)),
      );
    } on Object catch (error) {
      await stop();
      if (error is TrackingEngineFailureException) rethrow;
      throw TrackingEngineFailureException(
        engine: TrackingEngineType.gps,
        dependency: TrackingDependency.location,
        reason: TrackingEngineFailureReason.unrecoverableStreamFailure,
        cause: error,
      );
    }
  }

  void _emitMetrics() {
    final distanceKm = _totalDistance / 1000.0;
    final durationHours = _durationSec / 3600.0;
    final avgSpeedKmH = (durationHours > 0) ? (distanceKm / durationHours) : 0.0;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final signalStale = _lastProcessedMs > 0 && (nowMs - _lastProcessedMs) > _gpsStallTimeoutMs;

    final rawSpeedMps = _kalmanFilter.speedMetersPerSecond;
    final currentSpeedKmH = signalStale ? 0.0 : (rawSpeedMps < 0.15 ? 0.0 : rawSpeedMps) * 3.6;

    final avgPaceMinKm = avgSpeedKmH > 0 ? 60.0 / avgSpeedKmH : 0.0;
    final currentPaceMinKm = currentSpeedKmH > 0 ? 60.0 / currentSpeedKmH : 0.0;

    _controller.add(
      RunningMetrics(
        distanceMeters: _totalDistance,
        durationSeconds: _durationSec,
        avgSpeedKmH: avgSpeedKmH,
        currentSpeedKmH: currentSpeedKmH,
        avgPaceMinKm: avgPaceMinKm,
        currentPaceMinKm: currentPaceMinKm,
        stepCount: 0,
        currentLocation: _lastSmoothedPoint,
      ),
    );
  }

  @override
  void pause() {
    if (!_isRunning || _terminalFailureSent) return;
    _isPaused = true;
  }

  @override
  void resume() {
    if (!_isRunning || _terminalFailureSent) return;
    _isPaused = false;
    _lastSmoothedPoint = null;
    _lastAcceptedRawPoint = null;
    _lastAcceptedTimestampMs = null;
    _lastProcessedMs = 0;
    _kalmanFilter.reset();
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
    _ticker?.cancel();
    _ticker = null;
    _healthTimer?.cancel();
    _healthTimer = null;

    final positionSub = _positionSub;
    final serviceStatusSub = _serviceStatusSub;
    _positionSub = null;
    _serviceStatusSub = null;
    try {
      await Future.wait([
        if (positionSub != null) positionSub.cancel(),
        if (serviceStatusSub != null) serviceStatusSub.cancel(),
      ]);
    } finally {
      _isPaused = false;
      _isStopping = false;
    }
  }

  @override
  void reset() {
    _totalDistance = 0;
    _durationSec = 0;
    _lastSmoothedPoint = null;
    _lastAcceptedRawPoint = null;
    _lastAcceptedTimestampMs = null;
    _lastProcessedMs = 0;
    _kalmanFilter.reset();
  }

  LocationSettings _getFitnessLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        intervalDuration: RunningConstants.engineTickInterval,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
    }
  }

  bool _isImplausibleRawJump(Position position, int timestampMs) {
    final lastPoint = _lastAcceptedRawPoint;
    final lastTimestampMs = _lastAcceptedTimestampMs;
    if (lastPoint == null || lastTimestampMs == null) return false;

    final elapsedMs = timestampMs - lastTimestampMs;
    if (elapsedMs <= 0) return false;

    final distanceMeters = _geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      position.latitude,
      position.longitude,
    );
    final speedKmH = distanceMeters / (elapsedMs / 1000) * 3.6;
    return speedKmH > RunningConstants.maxHumanSpeedKmh;
  }

  Future<TrackingEngineFailureException?> _checkAvailabilityForStart() async {
    try {
      return await _sensorAvailability.gpsFailure();
    } on Object catch (error) {
      return TrackingEngineFailureException(
        engine: TrackingEngineType.gps,
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
      if (identical(_healthCheckInFlight, future)) _healthCheckInFlight = null;
    });
  }

  Future<void> _runHealthCheckInternal(int generation) async {
    if (!_isCurrentRun(generation)) return;
    try {
      final failure = await _sensorAvailability.gpsFailure();
      if (_isCurrentRun(generation) && failure != null) {
        _failOnce(failure);
      }
    } on Object catch (error, stackTrace) {
      logger.w('GpsTrackingEngine: health check failed: $error', error, stackTrace);
    }
  }

  Future<void> _handlePositionError(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) async {
    if (!_isCurrentRun(generation)) return;
    logger.e('GpsTrackingEngine: position stream error', error, stackTrace);

    if (error is PermissionDeniedException) {
      _failOnce(
        TrackingEngineFailureException(
          engine: TrackingEngineType.gps,
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
          engine: TrackingEngineType.gps,
          dependency: TrackingDependency.location,
          reason: TrackingEngineFailureReason.locationServiceDisabled,
          cause: error,
        ),
        stackTrace,
      );
      return;
    }

    try {
      final failure = await _sensorAvailability.gpsFailure();
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
        'GpsTrackingEngine: could not classify position error: $healthError',
        healthError,
        healthStackTrace,
      );
    }

    if (_isCurrentRun(generation)) {
      _controller.addError(SensorStreamException('gps', cause: error), stackTrace);
    }
  }

  void _handleUnexpectedStreamDone(int generation) {
    if (!_isCurrentRun(generation) || _isStopping) return;
    _failOnce(
      const TrackingEngineFailureException(
        engine: TrackingEngineType.gps,
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
    logger.e('GpsTrackingEngine: terminal failure', failure, stackTrace);
    _controller.addError(failure, stackTrace ?? StackTrace.current);
    unawaited(stop());
  }

  void _clearStopFuture(Future<void> future) {
    if (identical(_stopFuture, future)) _stopFuture = null;
  }

  /// Dispose when the singleton is torn down (e.g. during testing).
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
