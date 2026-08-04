import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/completed_set_identity.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/services/client_id_generator.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_program_exercise_binding.dart';

void main() {
  late _MockExerciseSessionRepository repository;
  late _MockAnalyticsService analytics;
  late _MockUserSessionService userSessionService;

  setUpAll(() {
    registerFallbackValue(WorkoutSet(id: -1));
    registerFallbackValue(MeasurementSystem.metric);
  });

  setUp(() {
    repository = _MockExerciseSessionRepository();
    analytics = _MockAnalyticsService();
    userSessionService = _MockUserSessionService();
    when(() => userSessionService.currentUser).thenReturn(null);
  });

  test('swapped initialization is explicit, idempotent, and skips previous result', () async {
    final cubit = ActiveExerciseCubit(
      repository,
      analytics,
      userSessionService,
      const ClientIdGenerator(),
      _swappedContext(notes: 'keep me'),
    );

    await cubit.initialize();
    await cubit.initialize();

    expect(cubit.state.notes, 'keep me');
    expect(cubit.state.previousResult, isNull);
    expect(cubit.state.sets, hasLength(1));
    expect(cubit.effectiveExercise.id, _swappedExercise.id);
    expect(cubit.isRunningExercise, isTrue);
    verifyNever(
      () => repository.getPreviousResults(
        workoutSessionId: any(named: 'workoutSessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        system: any(named: 'system'),
      ),
    );

    await cubit.close();
  });

  test('set and notes use effective exercise but retain original program exercise id', () async {
    final cubit = ActiveExerciseCubit(
      repository,
      analytics,
      userSessionService,
      const ClientIdGenerator(),
      _swappedContext(),
    );
    when(
      () => repository.completeSet(
        exerciseId: _swappedExercise.id,
        workoutSessionId: 10,
        exerciseSessionId: 100,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        CompletedSetIdentity(remoteSetId: 1, clientSetId: null),
      ),
    );
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(
      () => repository.saveWorkoutNote(
        exerciseSessionId: 100,
        note: 'runtime note',
      ),
    ).thenAnswer((_) async => const Result.success(null));

    cubit.replaceSetsFromExternalSource(
      sets: [WorkoutSet(id: 1, setNumber: 1, reps: 5)],
      isSending: false,
    );
    await cubit.markSetDone(1);
    cubit.setNote('runtime note');
    await cubit.finishExercise();

    expect(cubit.state.sets.single.isDone, isTrue);
    expect(cubit.state.isSubmitted, isTrue);
    verify(
      () => repository.completeSet(
        exerciseId: _swappedExercise.id,
        workoutSessionId: 10,
        exerciseSessionId: 100,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).called(1);
    verify(
      () => repository.saveWorkoutNote(
        exerciseSessionId: 100,
        note: 'runtime note',
      ),
    ).called(1);

    await cubit.close();
  });

  test('applies a confirmed repeated swap while preserving notes and resetting unfinished sets', () async {
    final cubit =
        ActiveExerciseCubit(
            repository,
            analytics,
            userSessionService,
            const ClientIdGenerator(),
            _swappedContext(notes: 'server note'),
          )
          ..replaceSetsFromExternalSource(
            sets: [WorkoutSet(id: 1, reps: 5)],
            isSending: false,
          )
          ..setNote('local note');

    final context = cubit.applySwap(
      AppliedExerciseSwap(
        session: _swapResponse(_regularReplacement.id),
        exercise: _regularReplacement,
      ),
    );

    expect(context?.session.id, 100);
    expect(context?.effectiveExercise.id, _regularReplacement.id);
    expect(context?.session.notes, 'local note');
    expect(cubit.state.notes, 'local note');
    expect(cubit.state.sets, hasLength(1));
    expect(cubit.state.sets.single.isEmpty, isTrue);
    expect(cubit.state.previousResult, isNull);
    expect(cubit.isRunningExercise, isFalse);

    final runningContext = cubit.applySwap(
      AppliedExerciseSwap(
        session: _swapResponse(_runningReplacement.id),
        exercise: _runningReplacement,
      ),
    );

    expect(runningContext?.effectiveExercise.id, _runningReplacement.id);
    expect(cubit.state.sets, isEmpty);
    expect(cubit.state.notes, 'local note');
    expect(cubit.isRunningExercise, isTrue);

    await cubit.close();
  });

  test('does not allow opening swap after a completed set', () async {
    final cubit =
        ActiveExerciseCubit(
          repository,
          analytics,
          userSessionService,
          const ClientIdGenerator(),
          _swappedContext(),
        )..replaceSetsFromExternalSource(
          sets: [WorkoutSet(id: 1, reps: 5, isDone: true)],
          isSending: false,
        );

    expect(cubit.canSwap, isFalse);

    await cubit.close();
  });

  test('ad-hoc execution skips program behavior and sends set and notes by session identity', () async {
    final cubit = ActiveExerciseCubit(
      repository,
      analytics,
      userSessionService,
      const ClientIdGenerator(),
      _freeRunExecution(),
    );
    final set = WorkoutSet(
      id: 1,
      clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
      setNumber: 1,
      time: const Duration(seconds: 60),
      distance: 1,
    );
    when(
      () => repository.completeSet(
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        CompletedSetIdentity(remoteSetId: 368, clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93'),
      ),
    );
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(
      () => repository.saveWorkoutNote(
        exerciseSessionId: 246,
        note: 'outdoor intervals',
      ),
    ).thenAnswer((_) async => const Result.success(null));

    await cubit.initialize();

    expect(cubit.state.previousResult, isNull);
    expect(cubit.canSwap, isFalse);
    expect(cubit.isRunningExercise, isTrue);
    verifyNever(
      () => repository.getPreviousResults(
        workoutSessionId: any(named: 'workoutSessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        system: any(named: 'system'),
      ),
    );

    cubit.replaceSetsFromExternalSource(sets: [set], isSending: false);
    await cubit.markSetDone(set.id);
    cubit.setNote('outdoor intervals');
    await cubit.finishExercise();

    expect(cubit.state.isSubmitted, isTrue);
    verify(
      () => repository.completeSet(
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).called(1);
    verify(
      () => repository.saveWorkoutNote(
        exerciseSessionId: 246,
        note: 'outdoor intervals',
      ),
    ).called(1);

    await cubit.close();
  });
}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockUserSessionService extends Mock implements UserSessionService {}

ActiveExerciseExecution _swappedContext({String? notes}) {
  return ActiveExerciseExecution(
    spec: _programSpec,
    workoutSessionId: 10,
    session: WorkoutExerciseSessionEntity(
      id: 100,
      exerciseId: _plannedExercise.id,
      workoutSessionId: 10,
      workoutProgramExerciseId: 20,
      isSwapped: true,
      swappedExerciseId: _swappedExercise.id,
      isActive: true,
      notes: notes,
      lastCompletedSet: null,
      createdAt: null,
      updatedAt: null,
      sets: const [],
      exercise: _plannedExercise,
      swappedExercise: _swappedExercise,
    ),
    effectiveExercise: _swappedExercise,
  );
}

ActiveExerciseExecution _freeRunExecution() {
  return ActiveExerciseExecution(
    spec: const WorkoutExerciseSpec(
      executionKey: 'adHoc:4',
      details: _freeRunExercise,
      targetSetCount: null,
      segments: [],
      programBinding: null,
    ),
    workoutSessionId: 182,
    session: const WorkoutExerciseSessionEntity(
      id: 246,
      exerciseId: 4,
      workoutSessionId: 182,
      workoutProgramExerciseId: null,
      isSwapped: false,
      swappedExerciseId: null,
      isActive: true,
      notes: null,
      lastCompletedSet: null,
      createdAt: null,
      updatedAt: null,
      sets: [],
      exercise: _freeRunExercise,
      swappedExercise: null,
    ),
  );
}

WorkoutExerciseSessionEntity _swapResponse(int swappedExerciseId) {
  return WorkoutExerciseSessionEntity(
    id: 100,
    exerciseId: _plannedExercise.id,
    workoutSessionId: 10,
    workoutProgramExerciseId: 20,
    isSwapped: true,
    swappedExerciseId: swappedExerciseId,
    isActive: true,
    notes: '',
    lastCompletedSet: null,
    createdAt: null,
    updatedAt: null,
    sets: const [],
    exercise: null,
    swappedExercise: null,
  );
}

const _plannedExercise = ExerciseDetailsEntity(
  id: 30,
  name: 'Push-ups',
  description: 'Regular exercise',
  key: 'push_ups',
  metrics: [WorkoutMetric.reps],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _swappedExercise = ExerciseDetailsEntity(
  id: 40,
  name: 'Free run',
  description: 'Runtime running exercise',
  key: null,
  factionId: 3,
  metrics: [WorkoutMetric.reps],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _regularReplacement = ExerciseDetailsEntity(
  id: 41,
  name: 'Squats',
  description: 'Runtime regular exercise',
  key: null,
  factionId: 1,
  metrics: [WorkoutMetric.reps],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _runningReplacement = ExerciseDetailsEntity(
  id: 42,
  name: 'Running',
  description: 'Runtime running exercise',
  key: null,
  factionId: 3,
  metrics: [WorkoutMetric.time],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _freeRunExercise = ExerciseDetailsEntity(
  id: 4,
  name: 'Running',
  description: 'Free run',
  key: 'running',
  metrics: [WorkoutMetric.time, WorkoutMetric.distance],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _programSpec = WorkoutExerciseSpec(
  executionKey: 'program:20',
  details: _plannedExercise,
  targetSetCount: 1,
  segments: [],
  programBinding: WorkoutProgramExerciseBinding(
    programDayId: 1,
    programExerciseId: 20,
    order: 1,
    executionMode: ExecutionMode.standard,
  ),
);
