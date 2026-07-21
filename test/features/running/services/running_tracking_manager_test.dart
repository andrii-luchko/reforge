import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/running/data/services/audio_feedback_service.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

void main() {
  late MockLocalWorkoutSessionRepository repository;
  late MockAudioFeedbackService audio;
  late SynchronousMetricEngine pedometer;
  late SynchronousMetricEngine gps;

  setUp(() {
    repository = MockLocalWorkoutSessionRepository();
    audio = MockAudioFeedbackService();
    pedometer = SynchronousMetricEngine();
    gps = SynchronousMetricEngine();

    when(
      () => repository.getInProgressLapForExercise(
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.getLastLap(
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.createNewActiveSet(
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        setNumber: any(named: 'setNumber'),
        trackingMode: any(named: 'trackingMode'),
        programSegmentId: any(named: 'programSegmentId'),
        segmentType: any(named: 'segmentType'),
      ),
    ).thenAnswer((_) async => 1);
    when(
      () => repository.snapshotActiveLap(
        setId: any(named: 'setId'),
        distance: any(named: 'distance'),
        duration: any(named: 'duration'),
        avgSpeedKmH: any(named: 'avgSpeedKmH'),
        currentSpeedKmH: any(named: 'currentSpeedKmH'),
        avgPaceMinKm: any(named: 'avgPaceMinKm'),
        currentPaceMinKm: any(named: 'currentPaceMinKm'),
        stepCount: any(named: 'stepCount'),
      ),
    ).thenAnswer((_) async {});
    when(() => repository.markSetAsFinishedLocally(any())).thenAnswer((_) async {});
  });

  test('subscribes to engine metrics before engine.start', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);
    final firstMetric = manager.metricsStream.first;

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
    );

    expect((await firstMetric).durationSeconds, 1);
    await manager.endSession();
  });

  test('ignores duplicate start without pausing or restarting the engine', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
    );
    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
      startPaused: true,
    );

    expect(gps.startCalls, 1);
    expect(gps.pauseCalls, 0);
    await manager.endSession();
  });

  test('waits for engine shutdown before endSession completes', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);
    final stopCompleter = Completer<void>();
    gps.stopCompleter = stopCompleter;

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
    );

    var completed = false;
    final stopping = manager.endSession().whenComplete(() => completed = true);
    await Future<void>.delayed(Duration.zero);

    expect(completed, false);
    stopCompleter.complete();
    await stopping;
    expect(completed, true);
  });

  test('starts and emits metrics again after endSession', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
    );
    await manager.endSession();

    final nextMetric = manager.metricsStream.first;
    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 11,
      programExerciseId: 20,
    );

    expect((await nextMetric).durationSeconds, 1);
    expect(gps.startCalls, 2);
    expect(gps.stopCalls, 1);
    await manager.endSession();
  });

  test('starts lap numbering from one for another program exercise in the same session', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 111,
    );

    verify(
      () => repository.getLastLap(
        sessionId: 10,
        programExerciseId: 111,
      ),
    ).called(1);
    verify(
      () => repository.createNewActiveSet(
        sessionId: 10,
        programExerciseId: 111,
        setNumber: 1,
        trackingMode: RunningMode.gps.dbValue,
      ),
    ).called(1);

    await manager.endSession();
  });

  test('finalizes the active lap before forwarding a terminal engine failure', () async {
    final manager = RunningSessionManager(pedometer, gps, repository, audio);
    final markCompleted = Completer<void>();
    Future<void> waitForMark(Invocation _) => markCompleted.future;
    when(() => repository.markSetAsFinishedLocally(1)).thenAnswer(waitForMark);

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      programExerciseId: 20,
    );

    final forwardedError = Completer<Object>();
    final sub = manager.metricsStream.listen(
      (_) {},
      onError: forwardedError.complete,
    );
    const failure = TrackingEngineFailureException(
      engine: TrackingEngineType.gps,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationServiceDisabled,
    );

    gps.emitError(failure);
    await Future<void>.delayed(Duration.zero);

    expect(forwardedError.isCompleted, false);
    markCompleted.complete();
    expect(await forwardedError.future, same(failure));
    expect(manager.currentMode, isNull);
    verify(
      () => repository.snapshotActiveLap(
        setId: 1,
        distance: 1,
        duration: 1,
        avgSpeedKmH: 1,
        currentSpeedKmH: 1,
        avgPaceMinKm: 1,
        currentPaceMinKm: 1,
        stepCount: 0,
      ),
    ).called(1);
    verify(() => repository.markSetAsFinishedLocally(1)).called(1);
    expect(gps.stopCalls, 1);

    await sub.cancel();
  });
}

class MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class MockAudioFeedbackService extends Mock implements AudioFeedbackService {}

final class SynchronousMetricEngine implements TrackingEngine {
  final _controller = StreamController<RunningMetrics>.broadcast(sync: true);
  int startCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  Completer<void>? stopCompleter;

  void emitError(Object error) => _controller.addError(error, StackTrace.current);

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    startCalls++;
    _controller.add(
      const RunningMetrics(
        distanceMeters: 1,
        durationSeconds: 1,
        avgSpeedKmH: 1,
        currentSpeedKmH: 1,
        avgPaceMinKm: 1,
        currentPaceMinKm: 1,
        stepCount: 0,
      ),
    );
  }

  @override
  void pause() => pauseCalls++;

  @override
  void reset() {}

  @override
  void resume() {}

  @override
  Future<void> stop() async {
    stopCalls++;
    await stopCompleter?.future;
  }
}
