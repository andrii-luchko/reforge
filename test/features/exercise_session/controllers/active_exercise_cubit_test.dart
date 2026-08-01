import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';

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
      _swappedContext(),
    );
    when(
      () => repository.completeSet(
        exerciseId: _swappedExercise.id,
        workoutSessionId: 10,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(
      () => repository.saveWorkoutNote(
        exerciseId: _swappedExercise.id,
        workoutSessionId: 10,
        workoutProgramExerciseId: 20,
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
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).called(1);
    verify(
      () => repository.saveWorkoutNote(
        exerciseId: _swappedExercise.id,
        workoutSessionId: 10,
        workoutProgramExerciseId: 20,
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
          _swappedContext(),
        )..replaceSetsFromExternalSource(
          sets: [WorkoutSet(id: 1, reps: 5, isDone: true)],
          isSending: false,
        );

    expect(cubit.canSwap, isFalse);

    await cubit.close();
  });
}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockUserSessionService extends Mock implements UserSessionService {}

ActiveWorkoutExerciseContext _swappedContext({String? notes}) {
  return ActiveWorkoutExerciseContext(
    programExercise: _programExercise,
    session: WorkoutExerciseSessionEntity(
      id: 100,
      exerciseId: _plannedExercise.id,
      workoutSessionId: 10,
      workoutProgramExerciseId: _programExercise.id,
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

WorkoutExerciseSessionEntity _swapResponse(int swappedExerciseId) {
  return WorkoutExerciseSessionEntity(
    id: 100,
    exerciseId: _plannedExercise.id,
    workoutSessionId: 10,
    workoutProgramExerciseId: _programExercise.id,
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

const _programExercise = ProgramExerciseEntity(
  id: 20,
  programDayId: 1,
  sets: 1,
  order: 1,
  exerciseDetails: _plannedExercise,
  executionMode: ExecutionMode.standard,
  segments: [],
);
