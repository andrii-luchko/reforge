import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

void main() {
  late MockFlutterBackgroundService service;
  late Map<String, StreamController<Map<String, dynamic>?>> controllers;
  late RunningServiceClient client;

  setUp(() {
    service = MockFlutterBackgroundService();
    controllers = {};
    when(() => service.on(any())).thenAnswer((invocation) {
      final method = invocation.positionalArguments.first as String;
      return controllers
          .putIfAbsent(
            method,
            () => StreamController<Map<String, dynamic>?>.broadcast(sync: true),
          )
          .stream;
    });
    when(() => service.invoke(any(), any())).thenReturn(null);
    client = RunningServiceClient.withService(service);
  });

  tearDown(() async {
    await Future.wait(controllers.values.map((controller) => controller.close()));
  });

  test('warmUp starts an idle worker without starting a session', () async {
    when(() => service.isRunning()).thenAnswer((_) async => false);
    when(() => service.startService()).thenAnswer((_) async => true);

    await client.warmUp();

    verify(() => service.startService()).called(1);
    verifyNever(() => service.invoke('start_session', any()));
  });

  test('warmUp contains native errors so fire-and-forget callers stay safe', () async {
    when(() => service.isRunning()).thenAnswer((_) async => false);
    when(() => service.startService()).thenThrow(Exception('native start failed'));

    await expectLater(client.warmUp(), completes);

    verifyNever(() => service.invoke('start_session', any()));
  });

  test('startSession dispatches without service_ready or session_started', () async {
    when(() => service.isRunning()).thenAnswer((_) async => false);
    when(() => service.startService()).thenAnswer((_) async => true);

    await client.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 42,
      programExerciseId: 7,
    );

    verify(() => service.startService()).called(1);
    verify(
      () => service.invoke(
        'start_session',
        any(
          that: isA<Map<String, dynamic>>()
              .having((payload) => payload['sessionId'], 'sessionId', 42)
              .having((payload) => payload['mode'], 'mode', 'gps'),
        ),
      ),
    ).called(1);
    expect(client.currentMode, RunningMode.gps);
  });

  test('startSession reuses a warmed worker', () async {
    when(() => service.isRunning()).thenAnswer((_) async => true);

    await client.startSession(
      mode: RunningMode.pedometer,
      limits: const [],
      sessionId: 42,
      programExerciseId: 7,
    );

    verifyNever(() => service.startService());
    verify(() => service.invoke('start_session', any())).called(1);
  });

  test('a real native start failure is surfaced', () async {
    when(() => service.isRunning()).thenAnswer((_) async => false);
    when(() => service.startService()).thenAnswer((_) async => false);

    await expectLater(
      client.startSession(
        mode: RunningMode.gps,
        limits: const [],
        sessionId: 42,
        programExerciseId: 7,
      ),
      throwsA(
        isA<RunningServiceException>().having(
          (error) => error.code,
          'code',
          'background_service_start_failed',
        ),
      ),
    );

    verifyNever(() => service.invoke('start_session', any()));
  });

  test('metrics parser accepts integral iOS values represented as doubles', () async {
    await client.initialize();
    final metric = client.metricsStream.first;

    controllers['metrics']!.add({
      'distanceMeters': 12.5,
      'durationSeconds': 3.0,
      'avgSpeedKmH': 15.0,
      'currentSpeedKmH': 16.0,
      'avgPaceMinKm': 4.0,
      'currentPaceMinKm': 3.75,
      'stepCount': 6.0,
      'currentSegmentIndex': 1.0,
      'segmentId': 99.0,
      'activityType': 'run',
    });

    final result = await metric;
    expect(result.durationSeconds, 3);
    expect(result.stepCount, 6);
    expect(result.currentSegmentIndex, 1);
    expect(result.segmentId, 99);
  });
}

class MockFlutterBackgroundService extends Mock implements FlutterBackgroundService {}
