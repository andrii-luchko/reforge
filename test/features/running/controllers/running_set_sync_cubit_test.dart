import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/completed_set_identity.dart';
import 'package:reforge/features/exercise_session/domain/exceptions/set_idempotency_conflict_exception.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(WorkoutSet(id: -1));
  });

  test('sends and persists stable client and remote set identities', () async {
    final harness = _Harness(_runningConfig);
    final synced = Completer<void>();
    WorkoutSet? sentSet;
    harness.stubBase();
    when(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 10,
        exerciseSessionId: 100,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((invocation) async {
      sentSet = invocation.namedArguments[#set] as WorkoutSet;
      return const Result.success(
        CompletedSetIdentity(remoteSetId: 901, clientSetId: _clientSetId),
      );
    });
    when(
      () => harness.localRepository.markSetAsSynced(1, remoteSetId: 901),
    ).thenAnswer((_) async {
      if (!synced.isCompleted) synced.complete();
    });

    await harness.cubit.init();
    harness.rows.add(const [_locallyCompletedRow]);
    await synced.future.timeout(const Duration(seconds: 1));
    await _waitForState(harness.cubit, (state) => state.canFinish);

    expect(sentSet?.clientSetId, _clientSetId);
    expect(sentSet?.speed, 9);
    expect(sentSet?.pace, closeTo(60 / 9, 0.000001));
    expect(harness.cubit.state.sets.single.isDone, isTrue);
    expect(harness.cubit.state.canFinish, isTrue);
    verify(
      () => harness.localRepository.markSetAsSynced(1, remoteSetId: 901),
    ).called(1);

    await harness.close();
  });

  test('syncs ad-hoc row without a program binding', () async {
    final config = RunningExerciseConfig(
      workoutSessionId: 182,
      exerciseSessionId: 246,
      exercise: _runningProgramExercise.exerciseDetails,
      segments: const [],
      staticTargetSetCount: 1,
    );
    final harness = _Harness(config);
    final synced = Completer<void>();
    harness.stubBase();
    when(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        CompletedSetIdentity(remoteSetId: 368, clientSetId: _adHocClientSetId),
      ),
    );
    when(
      () => harness.localRepository.markSetAsSynced(2, remoteSetId: 368),
    ).thenAnswer((_) async {
      if (!synced.isCompleted) synced.complete();
    });

    await harness.cubit.init();
    harness.rows.add(const [_adHocLocallyCompletedRow]);
    await synced.future.timeout(const Duration(seconds: 1));

    verify(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).called(1);

    await harness.close();
  });

  test('reconciles a restored backend set by idempotency key before watching the outbox', () async {
    final harness = _Harness(_runningConfig)..stubBase();

    await harness.cubit.init(
      restoredSets: [
        WorkoutSet(
          id: 901,
          clientSetId: _clientSetId,
          isDone: true,
        ),
      ],
    );

    verifyInOrder([
      () => harness.localRepository.reconcileSetAsSynced(
        sessionId: 10,
        exerciseSessionId: 100,
        clientSetId: _clientSetId,
        remoteSetId: 901,
        durationSeconds: 0,
        distanceMeters: 0,
        speedKmH: 0,
      ),
      harness.localRepository.recoverInterruptedSetSyncs,
    ]);
    verify(
      () => harness.analytics.logEvent(
        AnalyticsEvents.runningSetReconciled,
        any(),
      ),
    ).called(1);

    await harness.close();
  });

  test('accepts a completed ad-hoc set with zero distance and duration', () async {
    final config = RunningExerciseConfig(
      workoutSessionId: 182,
      exerciseSessionId: 246,
      exercise: _runningProgramExercise.exerciseDetails,
      segments: const [],
      staticTargetSetCount: 1,
    );
    final harness = _Harness(config);
    final synced = Completer<void>();
    WorkoutSet? sentSet;
    harness.stubBase();
    when(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((invocation) async {
      sentSet = invocation.namedArguments[#set] as WorkoutSet;
      return const Result.success(
        CompletedSetIdentity(remoteSetId: 369, clientSetId: _zeroClientSetId),
      );
    });
    when(
      () => harness.localRepository.markSetAsSynced(3, remoteSetId: 369),
    ).thenAnswer((_) async {
      if (!synced.isCompleted) synced.complete();
    });

    await harness.cubit.init();
    harness.rows.add(const [_zeroAdHocLocallyCompletedRow]);
    await synced.future.timeout(const Duration(seconds: 1));
    await _waitForState(harness.cubit, (state) => state.canFinish);

    expect(sentSet?.distance, 0);
    expect(sentSet?.time, Duration.zero);
    expect(harness.cubit.state.canFinish, isTrue);

    await harness.close();
  });

  test('failed sync stays non-finishable and flush retries the same identity once', () async {
    final harness = _Harness(_runningConfig);
    final failed = Completer<void>();
    var attempts = 0;
    final sentClientIds = <String?>[];
    harness.stubBase();
    when(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 10,
        exerciseSessionId: 100,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((invocation) async {
      attempts++;
      sentClientIds.add((invocation.namedArguments[#set] as WorkoutSet).clientSetId);
      if (attempts == 1) return Result.error(Exception('offline'));
      return const Result.success(
        CompletedSetIdentity(remoteSetId: 901, clientSetId: _clientSetId),
      );
    });
    when(() => harness.localRepository.markSetSyncFailed(1)).thenAnswer((_) async {
      if (!failed.isCompleted) failed.complete();
    });
    when(
      () => harness.localRepository.markSetAsSynced(1, remoteSetId: 901),
    ).thenAnswer((_) async {});

    await harness.cubit.init();
    harness.rows.add(const [_locallyCompletedRow]);
    await failed.future.timeout(const Duration(seconds: 1));
    await _waitForState(
      harness.cubit,
      (state) => state.hasSyncFailures && !state.isSending,
    );

    expect(attempts, 1);
    expect(harness.cubit.state.canFinish, isFalse);
    expect(harness.cubit.state.hasSyncFailures, isTrue);

    final flushed = await harness.cubit.flush();

    expect(flushed, isTrue);
    expect(attempts, 2);
    expect(sentClientIds, [_clientSetId, _clientSetId]);
    verify(() => harness.localRepository.markSetAsSyncing(1)).called(2);

    await harness.close();
  });

  test('idempotency payload conflict is non-retryable', () async {
    final harness = _Harness(_runningConfig);
    final failed = Completer<void>();
    var attempts = 0;
    harness.stubBase();
    when(
      () => harness.exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 10,
        exerciseSessionId: 100,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((_) async {
      attempts++;
      return const Result.error(
        SetIdempotencyConflictException(idempotencyKey: _clientSetId),
      );
    });
    when(() => harness.localRepository.markSetSyncFailed(1)).thenAnswer((_) async {
      if (!failed.isCompleted) failed.complete();
    });

    await harness.cubit.init();
    harness.rows.add(const [_locallyCompletedRow]);
    await failed.future.timeout(const Duration(seconds: 1));
    await _waitForState(
      harness.cubit,
      (state) => state.hasSyncFailures && !state.isSending,
    );

    final flushed = await harness.cubit.flush();

    expect(flushed, isFalse);
    expect(attempts, 1);
    verify(
      () => harness.analytics.logEvent(
        AnalyticsEvents.runningSetSyncFailure,
        any(),
      ),
    ).called(1);
    verify(
      () => harness.analytics.logEvent(
        AnalyticsEvents.runningOutboxBlocked,
        any(),
      ),
    ).called(1);

    await harness.close();
  });
}

class _Harness {
  _Harness(RunningExerciseConfig config) {
    localRepository = _MockLocalWorkoutSessionRepository();
    exerciseRepository = _MockExerciseSessionRepository();
    analytics = _MockAnalyticsService();
    cubit = RunningSetSyncCubit(
      localRepository,
      exerciseRepository,
      analytics,
      config,
    );
  }

  late final _MockLocalWorkoutSessionRepository localRepository;
  late final _MockExerciseSessionRepository exerciseRepository;
  late final _MockAnalyticsService analytics;

  final rows = StreamController<List<ActiveRunningSet>>();
  late final RunningSetSyncCubit cubit;

  void stubBase() {
    reset(localRepository);
    reset(exerciseRepository);
    reset(analytics);
    when(localRepository.recoverInterruptedSetSyncs).thenAnswer((_) async {});
    when(
      () => localRepository.reconcileSetAsSynced(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        clientSetId: any(named: 'clientSetId'),
        remoteSetId: any(named: 'remoteSetId'),
        durationSeconds: any(named: 'durationSeconds'),
        distanceMeters: any(named: 'distanceMeters'),
        speedKmH: any(named: 'speedKmH'),
        programSegmentId: any(named: 'programSegmentId'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => localRepository.watchActiveRunningSets(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        workoutProgramExerciseId: any(named: 'workoutProgramExerciseId'),
      ),
    ).thenAnswer((_) => rows.stream);
    when(() => localRepository.markSetAsSyncing(any())).thenAnswer((_) async {});
    when(() => localRepository.markSetSyncFailed(any())).thenAnswer((_) async {});
    when(() => analytics.logEvent(any())).thenAnswer((_) async {});
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
  }

  Future<void> close() async {
    await cubit.close();
    await rows.close();
  }
}

Future<void> _waitForState(
  RunningSetSyncCubit cubit,
  bool Function(RunningSetSyncState state) predicate,
) async {
  if (predicate(cubit.state)) return;
  await cubit.stream.firstWhere(predicate).timeout(const Duration(seconds: 1));
}

class _MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

const _clientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf93';
const _adHocClientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf94';
const _zeroClientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf95';

const _locallyCompletedRow = ActiveRunningSet(
  id: 1,
  sessionId: 10,
  exerciseSessionId: 100,
  programExerciseId: 20,
  clientSetId: _clientSetId,
  setNumber: 1,
  distanceMeters: 1500,
  durationSeconds: 300,
  avgSpeedKmH: 9,
  avgPaceMinKm: 60 / 9,
  syncStatus: 'locallyCompleted',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _adHocLocallyCompletedRow = ActiveRunningSet(
  id: 2,
  sessionId: 182,
  exerciseSessionId: 246,
  clientSetId: _adHocClientSetId,
  setNumber: 1,
  distanceMeters: 1000,
  durationSeconds: 60,
  avgSpeedKmH: 10.5,
  avgPaceMinKm: 60 / 10.5,
  syncStatus: 'locallyCompleted',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _zeroAdHocLocallyCompletedRow = ActiveRunningSet(
  id: 3,
  sessionId: 182,
  exerciseSessionId: 246,
  clientSetId: _zeroClientSetId,
  setNumber: 1,
  distanceMeters: 0,
  durationSeconds: 0,
  avgSpeedKmH: 0,
  syncStatus: 'locallyCompleted',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _runningProgramExercise = ProgramExerciseEntity(
  id: 20,
  programDayId: 1,
  sets: 1,
  order: 1,
  executionMode: ExecutionMode.segmented,
  exerciseDetails: ExerciseDetailsEntity(
    id: 30,
    name: 'Run',
    description: 'Run',
    key: 'run',
    metrics: [WorkoutMetric.time, WorkoutMetric.distance],
    poseDetectionPreset: null,
    isTiered: false,
    tiers: [],
    videoInstructionUrl: null,
    thumbnailInstructionUrl: null,
    instructionsSteps: {},
  ),
  segments: [],
);

final _runningConfig = RunningExerciseConfig(
  workoutSessionId: 10,
  exerciseSessionId: 100,
  workoutProgramExerciseId: 20,
  exercise: _runningProgramExercise.exerciseDetails,
  segments: [],
  staticTargetSetCount: 1,
);
