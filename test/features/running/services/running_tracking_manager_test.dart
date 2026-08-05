import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/data/services/audio_feedback_service.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/adjustable_speed_tracking_engine.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  late MockLocalWorkoutSessionRepository repository;
  late MockAudioFeedbackService audio;
  late SynchronousMetricEngine pedometer;
  late SynchronousMetricEngine gps;
  late SynchronousMetricEngine treadmill;

  setUp(() {
    repository = MockLocalWorkoutSessionRepository();
    audio = MockAudioFeedbackService();
    pedometer = SynchronousMetricEngine();
    gps = SynchronousMetricEngine();
    treadmill = SynchronousMetricEngine();

    when(
      () => repository.getInProgressLapForExercise(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.getLastLap(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.createNewActiveSet(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
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
    when(() => audio.playLapCompleted()).thenAnswer((_) async {});
    when(() => audio.playWorkoutCompleted()).thenAnswer((_) async {});
  });

  test('subscribes to engine metrics before engine.start', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    final firstMetric = manager.metricsStream.first;

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
    );

    expect((await firstMetric).durationSeconds, 1);
    await manager.endSession();
  });

  test('applies treadmill speed before the first engine metric', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    final firstMetric = manager.metricsStream.first;

    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );

    expect((await firstMetric).currentSpeedKmH, 8);
    expect(treadmill.appliedSpeeds, [8]);
    expect(treadmill.startCalls, 1);
    expect(pedometer.startCalls, 0);
    expect(gps.startCalls, 0);
    verify(
      () => repository.createNewActiveSet(
        sessionId: 10,
        exerciseSessionId: 20,
        setNumber: 1,
        trackingMode: RunningMode.treadmill.dbValue,
      ),
    ).called(1);

    await manager.endSession();
  });

  test('persists the initial treadmill speed without waiting for the snapshot timer', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );

    verify(
      () => repository.snapshotActiveLap(
        setId: 1,
        distance: 1,
        duration: 1,
        avgSpeedKmH: 8,
        currentSpeedKmH: 8,
        avgPaceMinKm: 7.5,
        currentPaceMinKm: 7.5,
        stepCount: 0,
      ),
    ).called(1);

    await manager.endSession();
  });

  test('restore prefers persisted current treadmill speed over the startup fallback', () async {
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _activeTreadmillLap);
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      startPaused: true,
      initialSpeedKmH: 1,
    );

    expect(treadmill.appliedSpeeds, [9.4]);
    expect(treadmill.lastInitialOffset?.distanceMeters, 120);
    expect(treadmill.lastInitialOffset?.durationSeconds, 60);
    expect(treadmill.lastInitialOffset?.avgSpeedKmH, 7.2);
    expect(treadmill.lastInitialOffset?.currentSpeedKmH, 9.4);
    expect(treadmill.pauseCalls, 1);
    verifyNever(
      () => repository.createNewActiveSet(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        setNumber: any(named: 'setNumber'),
        trackingMode: any(named: 'trackingMode'),
        programSegmentId: any(named: 'programSegmentId'),
        segmentType: any(named: 'segmentType'),
      ),
    );

    await manager.endSession();
  });

  test('rejects treadmill start before creating a lap when speed is absent', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await expectLater(
      manager.startSession(
        mode: RunningMode.treadmill,
        limits: const [],
        sessionId: 10,
        exerciseSessionId: 20,
      ),
      throwsArgumentError,
    );

    expect(manager.currentMode, isNull);
    verifyNever(
      () => repository.createNewActiveSet(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        setNumber: any(named: 'setNumber'),
        trackingMode: any(named: 'trackingMode'),
        programSegmentId: any(named: 'programSegmentId'),
        segmentType: any(named: 'segmentType'),
      ),
    );
  });

  test('runtime treadmill speed emits and snapshots the applied value', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );
    final appliedMetric = manager.metricsStream.first;

    await manager.setTreadmillSpeed(10);

    expect((await appliedMetric).currentSpeedKmH, 10);
    expect(treadmill.appliedSpeeds, [8, 10]);
    verify(
      () => repository.snapshotActiveLap(
        setId: 1,
        distance: 1,
        duration: 1,
        avgSpeedKmH: 10,
        currentSpeedKmH: 10,
        avgPaceMinKm: 6,
        currentPaceMinKm: 6,
        stepCount: 0,
      ),
    ).called(1);

    await manager.endSession();
  });

  test('runtime treadmill speed is rejected in GPS mode', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
    );

    await expectLater(manager.setTreadmillSpeed(10), throwsStateError);

    expect(treadmill.appliedSpeeds, isEmpty);
    expect(manager.currentMode, RunningMode.gps);
    expect(gps.stopCalls, 0);
    await manager.endSession();
  });

  test('runtime treadmill speed is rejected in pedometer mode', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    await manager.startSession(
      mode: RunningMode.pedometer,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
    );

    await expectLater(manager.setTreadmillSpeed(10), throwsStateError);

    expect(treadmill.appliedSpeeds, isEmpty);
    expect(manager.currentMode, RunningMode.pedometer);
    expect(pedometer.stopCalls, 0);
    await manager.endSession();
  });

  test('invalid runtime speed leaves the treadmill session unchanged', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );

    await expectLater(manager.setTreadmillSpeed(0), throwsArgumentError);

    expect(treadmill.appliedSpeeds, [8]);
    expect(treadmill.currentSpeedKmH, 8);
    expect(manager.currentMode, RunningMode.treadmill);
    await manager.endSession();
  });

  test('lap reset retains the last treadmill speed', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    final completed = manager.eventsStream.firstWhere(
      (event) => event is LapCompletedEvent,
    );

    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [
        LapLimit(metric: WorkoutMetric.distance, limitValue: 1),
        LapLimit(metric: WorkoutMetric.distance, limitValue: 100),
      ],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );
    await completed;

    expect(treadmill.resetCalls, 1);
    expect(treadmill.currentSpeedKmH, 8);
    expect(treadmill.appliedSpeeds, [8]);
    await manager.endSession();
  });

  test('summary resume creates a new lap with the last treadmill speed', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    await manager.startSession(
      mode: RunningMode.treadmill,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      initialSpeedKmH: 8,
    );

    await manager.suspendSessionForSummary();
    await manager.resumeSession();

    expect(treadmill.resetCalls, 2);
    expect(treadmill.resumeCalls, 1);
    expect(treadmill.currentSpeedKmH, 8);
    verify(
      () => repository.createNewActiveSet(
        sessionId: 10,
        exerciseSessionId: 20,
        setNumber: 2,
        trackingMode: RunningMode.treadmill.dbValue,
      ),
    ).called(1);
    await manager.endSession();
  });

  test('ignores duplicate start without pausing or restarting the engine', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
    );
    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
      startPaused: true,
    );

    expect(gps.startCalls, 1);
    expect(gps.pauseCalls, 0);
    await manager.endSession();
  });

  test('waits for engine shutdown before endSession completes', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    final stopCompleter = Completer<void>();
    gps.stopCompleter = stopCompleter;

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
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
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
    );
    await manager.endSession();

    final nextMetric = manager.metricsStream.first;
    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 11,
      exerciseSessionId: 20,
    );

    expect((await nextMetric).durationSeconds, 1);
    expect(gps.startCalls, 2);
    expect(gps.stopCalls, 1);
    await manager.endSession();
  });

  test('starts lap numbering from one for another exercise session in the same workout', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 111,
    );

    verify(
      () => repository.getLastLap(
        sessionId: 10,
        exerciseSessionId: 111,
      ),
    ).called(1);
    verify(
      () => repository.createNewActiveSet(
        sessionId: 10,
        exerciseSessionId: 111,
        setNumber: 1,
        trackingMode: RunningMode.gps.dbValue,
      ),
    ).called(1);

    await manager.endSession();
  });

  for (final scenario in <({WorkoutMetric metric, String name})>[
    (metric: WorkoutMetric.distance, name: 'distance'),
    (metric: WorkoutMetric.time, name: 'time'),
  ]) {
    test('${scenario.name} limit automatically completes the planned set', () async {
      final manager = RunningSessionManager(
        pedometer,
        gps,
        treadmill,
        repository,
        audio,
      );
      final completed = manager.eventsStream.firstWhere((event) => event is PlannedWorkoutCompletedEvent);

      await manager.startSession(
        mode: RunningMode.gps,
        limits: [LapLimit(metric: scenario.metric, limitValue: 1)],
        sessionId: 10,
        exerciseSessionId: 20,
      );

      await completed;
      await Future<void>.delayed(Duration.zero);

      verify(() => repository.markSetAsFinishedLocally(1)).called(1);
      expect(gps.pauseCalls, 1);
      verifyNever(
        () => repository.createNewActiveSet(
          sessionId: 10,
          exerciseSessionId: 20,
          setNumber: 2,
          trackingMode: RunningMode.gps.dbValue,
        ),
      );

      await manager.endSession();
    });
  }

  test('restored completed plan stays on the next index and resumes with a free set', () async {
    when(
      () => repository.getLastLap(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _completedLap);
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [
        LapLimit(metric: WorkoutMetric.distance, limitValue: 3000),
      ],
      sessionId: 10,
      exerciseSessionId: 20,
      startPaused: true,
      restoreCompletedPlan: true,
    );

    verifyNever(
      () => repository.createNewActiveSet(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        setNumber: any(named: 'setNumber'),
        trackingMode: any(named: 'trackingMode'),
        programSegmentId: any(named: 'programSegmentId'),
        segmentType: any(named: 'segmentType'),
      ),
    );

    await manager.suspendSessionForSummary();
    await manager.suspendSessionForSummary();
    await manager.resumeSession();

    verify(
      () => repository.createNewActiveSet(
        sessionId: 10,
        exerciseSessionId: 20,
        setNumber: 2,
        trackingMode: RunningMode.gps.dbValue,
      ),
    ).called(1);
    expect(gps.resetCalls, 1);
    expect(gps.resumeCalls, 1);

    await manager.endSession();
  });

  test('finalizes the active lap before forwarding a terminal engine failure', () async {
    final manager = RunningSessionManager(
      pedometer,
      gps,
      treadmill,
      repository,
      audio,
    );
    final markCompleted = Completer<void>();
    Future<void> waitForMark(Invocation _) => markCompleted.future;
    when(() => repository.markSetAsFinishedLocally(1)).thenAnswer(waitForMark);

    await manager.startSession(
      mode: RunningMode.gps,
      limits: const [],
      sessionId: 10,
      exerciseSessionId: 20,
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
        avgPaceMinKm: 60,
        currentPaceMinKm: 60,
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

final class SynchronousMetricEngine implements AdjustableSpeedTrackingEngine {
  final _controller = StreamController<RunningMetrics>.broadcast(sync: true);
  int startCalls = 0;
  int pauseCalls = 0;
  int resetCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;
  Completer<void>? stopCompleter;
  final appliedSpeeds = <double>[];
  RunningMetrics? lastInitialOffset;
  double currentSpeedKmH = 1;
  bool isRunning = false;

  void emitError(Object error) => _controller.addError(error, StackTrace.current);

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    startCalls++;
    lastInitialOffset = initialOffset;
    isRunning = true;
    _emitMetrics();
  }

  void _emitMetrics() {
    _controller.add(
      RunningMetrics(
        distanceMeters: 1,
        durationSeconds: 1,
        avgSpeedKmH: currentSpeedKmH,
        currentSpeedKmH: currentSpeedKmH,
        avgPaceMinKm: 60 / currentSpeedKmH,
        currentPaceMinKm: 60 / currentSpeedKmH,
        stepCount: 0,
      ),
    );
  }

  @override
  void setSpeedKmH(double speedKmH) {
    appliedSpeeds.add(speedKmH);
    currentSpeedKmH = speedKmH;
    if (isRunning) _emitMetrics();
  }

  @override
  void pause() => pauseCalls++;

  @override
  void reset() => resetCalls++;

  @override
  void resume() => resumeCalls++;

  @override
  Future<void> stop() async {
    stopCalls++;
    isRunning = false;
    await stopCompleter?.future;
  }
}

const _completedLap = ActiveRunningSet(
  id: 1,
  sessionId: 10,
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
  setNumber: 1,
  distanceMeters: 3000,
  durationSeconds: 720,
  syncStatus: 'synced',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _activeTreadmillLap = ActiveRunningSet(
  id: 2,
  sessionId: 10,
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf94',
  setNumber: 1,
  distanceMeters: 120,
  durationSeconds: 60,
  avgSpeedKmH: 7.2,
  currentSpeedKmH: 9.4,
  avgPaceMinKm: 60 / 7.2,
  currentPaceMinKm: 60 / 9.4,
  stepCount: 0,
  syncStatus: 'tracking',
  trackingMode: 'treadmill',
  segmentType: 'run',
);
