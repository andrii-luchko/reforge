import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/features/running/data/services/pedometer_tracking_engine.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/running_sensor_availability.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  late FakeRunningSensorAvailability availability;
  late MockGeolocatorPlatform geolocator;
  late StreamController<StepCount> steps;
  late StreamController<PedestrianStatus> pedestrianStatuses;
  late StreamController<Position> keepAlivePositions;
  late StreamController<ServiceStatus> locationServiceStatuses;
  late PedometerTrackingEngine Function(TargetPlatform platform) buildEngine;

  setUp(() {
    availability = FakeRunningSensorAvailability();
    geolocator = MockGeolocatorPlatform();
    steps = StreamController<StepCount>.broadcast();
    pedestrianStatuses = StreamController<PedestrianStatus>.broadcast();
    keepAlivePositions = StreamController<Position>.broadcast();
    locationServiceStatuses = StreamController<ServiceStatus>.broadcast();
    when(
      () => geolocator.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => keepAlivePositions.stream);
    when(geolocator.getServiceStatusStream).thenAnswer((_) => locationServiceStatuses.stream);
    buildEngine = (platform) => PedometerTrackingEngine(
      sensorAvailability: availability,
      geolocator: geolocator,
      platform: platform,
      stepCountStream: () => steps.stream,
      pedestrianStatusStream: () => pedestrianStatuses.stream,
      healthCheckInterval: const Duration(milliseconds: 10),
    );
  });

  tearDown(() async {
    await steps.close();
    await pedestrianStatuses.close();
    await keepAlivePositions.close();
    await locationServiceStatuses.close();
  });

  test('fails before subscribing when motion permission is unavailable', () async {
    availability.pedometerResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.pedometer,
      dependency: TrackingDependency.motion,
      reason: TrackingEngineFailureReason.motionPermissionDenied,
    );
    final engine = buildEngine(TargetPlatform.android);

    await expectLater(
      engine.start(),
      throwsA(
        isA<TrackingEngineFailureException>().having(
          (error) => error.reason,
          'reason',
          TrackingEngineFailureReason.motionPermissionDenied,
        ),
      ),
    );
    expect(steps.hasListener, false);
    await engine.dispose();
  });

  test('treats a step counter platform error as terminal sensor failure', () async {
    final engine = buildEngine(TargetPlatform.android);
    await engine.start();
    final terminalError = _firstError(engine.metricsStream);

    steps.addError(
      PlatformException(code: '3', message: 'Step Count is not available'),
      StackTrace.current,
    );

    final error = await terminalError as TrackingEngineFailureException;
    expect(error.reason, TrackingEngineFailureReason.sensorUnavailable);
    expect(error.dependency, TrackingDependency.motion);
    await engine.dispose();
  });

  test('health checks detect revoked motion permission while paused', () async {
    final engine = buildEngine(TargetPlatform.android);
    await engine.start();
    engine.pause();
    final terminalError = _firstError(engine.metricsStream);
    availability.pedometerResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.pedometer,
      dependency: TrackingDependency.motion,
      reason: TrackingEngineFailureReason.motionPermissionDenied,
    );

    final error = await terminalError as TrackingEngineFailureException;
    expect(error.reason, TrackingEngineFailureReason.motionPermissionDenied);
    expect(availability.pedometerChecks, greaterThan(1));
    await engine.dispose();
  });

  test('does not fail merely because no step events arrive', () async {
    final engine = buildEngine(TargetPlatform.android);
    final errors = <Object>[];
    final sub = engine.metricsStream.listen((_) {}, onError: errors.add);

    await engine.start();
    await Future<void>.delayed(const Duration(milliseconds: 35));

    expect(errors, isEmpty);
    expect(steps.hasListener, true);
    await sub.cancel();
    await engine.dispose();
  });

  test('keeps running when the optional pedestrian status stream fails', () async {
    final engine = buildEngine(TargetPlatform.android);
    final errors = <Object>[];
    final sub = engine.metricsStream.listen((_) {}, onError: errors.add);
    await engine.start();

    pedestrianStatuses.addError(Exception('status unavailable'), StackTrace.current);
    await Future<void>.delayed(Duration.zero);

    expect(errors, isEmpty);
    expect(steps.hasListener, true);
    await sub.cancel();
    await engine.dispose();
  });

  test('stops iOS pedometer when location keep-alive permission is lost', () async {
    final engine = buildEngine(TargetPlatform.iOS);
    await engine.start();
    final terminalError = _firstError(engine.metricsStream);
    availability.pedometerResult = const TrackingEngineFailureException(
      engine: TrackingEngineType.pedometer,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationPermissionDenied,
    );

    keepAlivePositions.addError(
      const PositionUpdateException('Core Location denied'),
      StackTrace.current,
    );

    final error = await terminalError as TrackingEngineFailureException;
    expect(error.reason, TrackingEngineFailureReason.locationPermissionDenied);
    expect(error.dependency, TrackingDependency.location);
    await engine.dispose();
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
  int pedometerChecks = 0;

  @override
  Future<TrackingEngineFailureException?> gpsFailure() async => gpsResult;

  @override
  Future<TrackingEngineFailureException?> pedometerFailure() async {
    pedometerChecks++;
    return pedometerResult;
  }
}
