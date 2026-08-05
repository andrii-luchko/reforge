import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/running/data/services/treadmill_background_keep_alive.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/running_sensor_availability.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  late FakeRunningSensorAvailability availability;
  late MockGeolocatorPlatform geolocator;
  late StreamController<Position> positions;
  late StreamController<ServiceStatus> serviceStatuses;

  setUp(() {
    availability = FakeRunningSensorAvailability();
    geolocator = MockGeolocatorPlatform();
    positions = StreamController<Position>.broadcast();
    serviceStatuses = StreamController<ServiceStatus>.broadcast();
    when(
      () => geolocator.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => positions.stream);
    when(geolocator.getServiceStatusStream).thenAnswer((_) => serviceStatuses.stream);
  });

  tearDown(() async {
    await positions.close();
    await serviceStatuses.close();
  });

  test('uses a no-op path on Android without checking location', () async {
    final keepAlive = LocationTreadmillBackgroundKeepAlive(
      sensorAvailability: availability,
      geolocator: geolocator,
      platform: TargetPlatform.android,
    );

    await keepAlive.start();

    expect(availability.treadmillChecks, 0);
    verifyNever(geolocator.getServiceStatusStream);
    verifyNever(
      () => geolocator.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
    await keepAlive.dispose();
  });

  test('fails iOS preflight before subscribing when location is unavailable', () async {
    availability.treadmillResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.treadmill,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationPermissionDenied,
    );
    final keepAlive = LocationTreadmillBackgroundKeepAlive(
      sensorAvailability: availability,
      geolocator: geolocator,
      platform: TargetPlatform.iOS,
    );

    await expectLater(
      keepAlive.start(),
      throwsA(
        isA<TrackingEngineFailureException>().having(
          (error) => error.reason,
          'reason',
          TrackingEngineFailureReason.locationPermissionDenied,
        ),
      ),
    );

    verifyNever(geolocator.getServiceStatusStream);
    await keepAlive.dispose();
  });

  test('reports location service loss as a terminal treadmill failure', () async {
    final keepAlive = LocationTreadmillBackgroundKeepAlive(
      sensorAvailability: availability,
      geolocator: geolocator,
      platform: TargetPlatform.iOS,
    );
    await keepAlive.start();
    final failure = keepAlive.failures.first;

    serviceStatuses.add(ServiceStatus.disabled);

    final result = await failure;
    expect(result.engine, TrackingEngineType.treadmill);
    expect(result.dependency, TrackingDependency.location);
    expect(
      result.reason,
      TrackingEngineFailureReason.locationServiceDisabled,
    );
    await keepAlive.dispose();
  });

  test('health check detects permission loss while tracking', () async {
    final keepAlive = LocationTreadmillBackgroundKeepAlive(
      sensorAvailability: availability,
      geolocator: geolocator,
      platform: TargetPlatform.iOS,
      healthCheckInterval: const Duration(milliseconds: 10),
    );
    await keepAlive.start();
    final failure = keepAlive.failures.first;
    availability.treadmillResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.treadmill,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationPermissionDenied,
    );

    final result = await failure;

    expect(result.reason, TrackingEngineFailureReason.locationPermissionDenied);
    expect(availability.treadmillChecks, greaterThan(1));
    await keepAlive.dispose();
  });
}

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

class FakeRunningSensorAvailability implements RunningSensorAvailability {
  TrackingEngineFailureException? treadmillResult;
  int treadmillChecks = 0;

  @override
  Future<TrackingEngineFailureException?> gpsFailure() async => null;

  @override
  Future<TrackingEngineFailureException?> treadmillFailure() async {
    treadmillChecks++;
    return treadmillResult;
  }

  @override
  Future<TrackingEngineFailureException?> pedometerFailure() async => null;
}
