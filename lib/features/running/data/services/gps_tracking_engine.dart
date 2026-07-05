import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/kalman_location_filter.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

class GpsTrackingEngine implements TrackingEngine {
  final _controller = StreamController<RunningMetrics>.broadcast();

  Timer? _ticker;
  StreamSubscription<Position>? _positionSub;

  double _totalDistance = 0;
  int _durationSec = 0;
  int _lastProcessedMs = 0; // wall-clock time of the last successful Kalman update
  static const int _gpsStallTimeoutMs = 5000;
  RouteCoordinate? _lastSmoothedPoint;
  bool _isPaused = false;

  final _kalmanFilter = KalmanLocationFilter();

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (initialOffset != null) {
      _totalDistance = initialOffset.distanceMeters;
      _durationSec = initialOffset.durationSeconds;
    }

    _isPaused = false;
    _lastSmoothedPoint = null;
    _kalmanFilter.reset();

    // Start 1-sec ticker for time and pace updates
    _ticker?.cancel();
    _ticker = Timer.periodic(RunningConstants.engineTickInterval, (_) {
      if (_isPaused) return;
      _durationSec++;
      _emitMetrics();
    });

    // Start GPS stream
    await _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: _getFitnessLocationSettings(),
        ).listen(
          (pos) {
            if (_isPaused) return;

            // Process the raw point through Kalman Filter
            _kalmanFilter.process(
              lat: pos.latitude,
              lng: pos.longitude,
              accuracy: pos.accuracy,
              timestampMs: pos.timestamp.millisecondsSinceEpoch,
            );

            if (!_kalmanFilter.hasValidState) return;

            _lastProcessedMs = DateTime.now().millisecondsSinceEpoch;

            final smoothedLat = _kalmanFilter.latitude;
            final smoothedLng = _kalmanFilter.longitude;
            final smoothedHeading = _kalmanFilter.heading;

            if (_lastSmoothedPoint == null) {
              _lastSmoothedPoint = RouteCoordinate(
                latitude: smoothedLat,
                longitude: smoothedLng,
                heading: smoothedHeading,
              );
              return;
            }

            final distanceDelta = Geolocator.distanceBetween(
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
          },
          onError: (Object e, StackTrace st) {
            // GPS errors are recoverable (signal lost, brief hardware glitch).
            // We log and continue — the ticker keeps time even without position.
            // If the OS revokes permission entirely, the next position event
            // will throw again, and we'll log it again. That is acceptable.
            logger.e('GpsTrackingEngine: position stream error', e, st);
            _controller.addError(
              SensorUnavailableException('gps', cause: e),
              st,
            );
          },
          // CRITICAL: do NOT cancel the subscription on a single error.
          // GPS signal can be temporarily lost (tunnel, indoors) and restored.
          cancelOnError: false,
        );
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
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
    _lastSmoothedPoint = null;
  }

  @override
  void stop() {
    _ticker?.cancel();
    unawaited(_positionSub?.cancel());
  }

  @override
  void reset() {
    _totalDistance = 0;
    _durationSec = 0;
    _lastSmoothedPoint = null;
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
}
