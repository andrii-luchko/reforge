import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/running/data/services/gps_tracking_engine.dart';
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
  late GpsTrackingEngine engine;

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

    engine = GpsTrackingEngine(
      sensorAvailability: availability,
      geolocator: geolocator,
      healthCheckInterval: const Duration(milliseconds: 10),
    );
  });

  tearDown(() async {
    await engine.dispose();
    await positions.close();
    await serviceStatuses.close();
  });

  test('fails before subscribing when location is unavailable at start', () async {
    availability.gpsResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.gps,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationServiceDisabled,
    );

    await expectLater(
      engine.start(),
      throwsA(
        isA<TrackingEngineFailureException>().having(
          (error) => error.reason,
          'reason',
          TrackingEngineFailureReason.locationServiceDisabled,
        ),
      ),
    );

    verifyNever(
      () => geolocator.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  test('classifies an iOS position update failure using current availability', () async {
    await engine.start();
    final terminalError = _firstError(engine.metricsStream);
    availability.gpsResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.gps,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationPermissionDenied,
    );

    positions.addError(
      const PositionUpdateException(
        'The operation couldn’t be completed. (kCLErrorDomain error 1.)',
      ),
      StackTrace.current,
    );

    final error = await terminalError;
    expect(error, isA<TrackingEngineFailureException>());
    expect(
      (error as TrackingEngineFailureException).reason,
      TrackingEngineFailureReason.locationPermissionDenied,
    );
  });

  test('keeps the position stream alive after a recoverable error', () async {
    await engine.start();
    final recoverableError = _firstError(engine.metricsStream);

    positions.addError(
      const PositionUpdateException('Temporary location failure'),
      StackTrace.current,
    );

    expect(await recoverableError, isA<SensorStreamException>());
    expect(positions.hasListener, true);
  });

  test('treats unexpected position stream completion as terminal', () async {
    await engine.start();
    final terminalError = _firstError(engine.metricsStream);

    await positions.close();

    final error = await terminalError as TrackingEngineFailureException;
    expect(error.reason, TrackingEngineFailureReason.streamClosed);
  });

  test('health checks continue while the user has paused tracking', () async {
    await engine.start();
    engine.pause();
    final terminalError = _firstError(engine.metricsStream);
    availability.gpsResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.gps,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationServiceDisabled,
    );

    final error = await terminalError as TrackingEngineFailureException;
    expect(error.reason, TrackingEngineFailureReason.locationServiceDisabled);
    expect(availability.gpsChecks, greaterThan(1));
  });
}

Future<Object> _firstError(Stream<Object?> stream) {
  final completer = Completer<Object>();
  late StreamSubscription<Object?> subscription;
  subscription = stream.listen(
    (_) {},
    onError: (Object error) {
      if (!completer.isCompleted) completer.complete(error);
      unawaited(subscription.cancel());
    },
  );
  return completer.future;
}

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

class FakeRunningSensorAvailability implements RunningSensorAvailability {
  TrackingEngineFailureException? gpsResult;
  TrackingEngineFailureException? pedometerResult;
  int gpsChecks = 0;

  @override
  Future<TrackingEngineFailureException?> gpsFailure() async {
    gpsChecks++;
    return gpsResult;
  }

  @override
  Future<TrackingEngineFailureException?> pedometerFailure() async => pedometerResult;
}
