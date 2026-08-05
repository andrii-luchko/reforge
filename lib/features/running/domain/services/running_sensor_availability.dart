import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

/// Read-only checks for the platform dependencies required by tracking.
///
/// This service never requests a permission and is therefore safe to call from
/// the background tracking isolate.
abstract interface class RunningSensorAvailability {
  Future<TrackingEngineFailureException?> gpsFailure();

  Future<TrackingEngineFailureException?> treadmillFailure();
}

class RunningSensorAvailabilityService implements RunningSensorAvailability {
  RunningSensorAvailabilityService({TargetPlatform? platform}) : _platform = platform ?? defaultTargetPlatform;

  final TargetPlatform _platform;

  @override
  Future<TrackingEngineFailureException?> gpsFailure() {
    return _locationFailure(TrackingEngineType.gps);
  }

  @override
  Future<TrackingEngineFailureException?> treadmillFailure() async {
    if (_platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS) {
      return _locationFailure(TrackingEngineType.treadmill);
    }

    if (_platform == TargetPlatform.android) return null;

    return TrackingEngineFailureException(
      engine: TrackingEngineType.treadmill,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.sensorUnavailable,
      cause: UnsupportedError(
        'Manual treadmill tracking is not supported on ${_platform.name}',
      ),
    );
  }

  Future<TrackingEngineFailureException?> _locationFailure(
    TrackingEngineType engine,
  ) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return TrackingEngineFailureException(
        engine: engine,
        dependency: TrackingDependency.location,
        reason: TrackingEngineFailureReason.locationServiceDisabled,
      );
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return TrackingEngineFailureException(
        engine: engine,
        dependency: TrackingDependency.location,
        reason: TrackingEngineFailureReason.locationPermissionDenied,
      );
    }

    return null;
  }
}
