import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

/// Read-only checks for the platform dependencies required by tracking.
///
/// This service never requests a permission and is therefore safe to call from
/// the background tracking isolate.
abstract interface class RunningSensorAvailability {
  Future<TrackingEngineFailureException?> gpsFailure();

  Future<TrackingEngineFailureException?> pedometerFailure();
}

class RunningSensorAvailabilityService implements RunningSensorAvailability {
  RunningSensorAvailabilityService({TargetPlatform? platform}) : _platform = platform ?? defaultTargetPlatform;

  final TargetPlatform _platform;

  @override
  Future<TrackingEngineFailureException?> gpsFailure() {
    return _locationFailure(TrackingEngineType.gps);
  }

  @override
  Future<TrackingEngineFailureException?> pedometerFailure() async {
    if (_platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS) {
      final motionStatus = await Permission.sensors.status;
      if (!motionStatus.isGranted) {
        return const TrackingEngineFailureException(
          engine: TrackingEngineType.pedometer,
          dependency: TrackingDependency.motion,
          reason: TrackingEngineFailureReason.motionPermissionDenied,
        );
      }

      return _locationFailure(TrackingEngineType.pedometer);
    }

    if (_platform == TargetPlatform.android) {
      final motionStatus = await Permission.activityRecognition.status;
      if (!motionStatus.isGranted) {
        return const TrackingEngineFailureException(
          engine: TrackingEngineType.pedometer,
          dependency: TrackingDependency.motion,
          reason: TrackingEngineFailureReason.motionPermissionDenied,
        );
      }
      return null;
    }

    return TrackingEngineFailureException(
      engine: TrackingEngineType.pedometer,
      dependency: TrackingDependency.motion,
      reason: TrackingEngineFailureReason.sensorUnavailable,
      cause: UnsupportedError('Pedometer is not supported on ${_platform.name}'),
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
