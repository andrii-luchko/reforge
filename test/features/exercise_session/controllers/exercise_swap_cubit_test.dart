// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

void main() {
  late _MockExerciseSessionRepository exerciseRepository;
  late _MockWorkoutSessionRepository workoutRepository;
  late ExerciseSwapCubit cubit;

  setUp(() {
    exerciseRepository = _MockExerciseSessionRepository();
    workoutRepository = _MockWorkoutSessionRepository();
    cubit = ExerciseSwapCubit(exerciseRepository, workoutRepository, _requestContext);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads first page and filters the current effective exercise', () async {
    _stubSearch(
      exerciseRepository,
      page: 1,
      pages: 2,
      exercises: const [_currentExercise, _exercise12],
    );

    await cubit.initialize();

    expect(cubit.state.exercises, [_exercise12]);
    expect(cubit.state.hasMore, isTrue);
    verify(
      () => exerciseRepository.searchSwapExercises(
        search: null,
        factionId: null,
        page: 1,
        limit: ExerciseSwapCubit.pageLimit,
      ),
    ).called(1);
  });

  test('merges pagination by exercise id without duplicates', () async {
    _stubSearch(
      exerciseRepository,
      page: 1,
      pages: 2,
      exercises: const [_exercise12],
    );
    _stubSearch(
      exerciseRepository,
      page: 2,
      pages: 2,
      exercises: const [_exercise12, _exercise13],
    );

    await cubit.initialize();
    await cubit.loadMore();

    expect(cubit.state.exercises, const [_exercise12, _exercise13]);
    expect(cubit.state.hasMore, isFalse);
  });

  test('ignores an older search response after the query changes', () async {
    _stubSearch(exerciseRepository, page: 1, pages: 1, exercises: const []);
    await cubit.initialize();
    final oldResponse = Completer<Result<SwapExerciseSearchPage>>();
    final newResponse = Completer<Result<SwapExerciseSearchPage>>();
    when(
      () => exerciseRepository.searchSwapExercises(
        search: 'old',
        factionId: null,
        page: 1,
        limit: ExerciseSwapCubit.pageLimit,
      ),
    ).thenAnswer((_) => oldResponse.future);
    when(
      () => exerciseRepository.searchSwapExercises(
        search: 'new',
        factionId: null,
        page: 1,
        limit: ExerciseSwapCubit.pageLimit,
      ),
    ).thenAnswer((_) => newResponse.future);

    cubit.searchChanged('old');
    await Future<void>.delayed(ExerciseSwapCubit.searchDebounce + const Duration(milliseconds: 20));
    cubit.searchChanged('new');
    await Future<void>.delayed(ExerciseSwapCubit.searchDebounce + const Duration(milliseconds: 20));
    newResponse.complete(_searchResult(exercises: const [_exercise13]));
    await Future<void>.delayed(Duration.zero);
    oldResponse.complete(_searchResult(exercises: const [_exercise12]));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.query, 'new');
    expect(cubit.state.exercises, const [_exercise13]);
  });

  test('returns AppliedExerciseSwap only after PATCH confirms the selected id', () async {
    _stubSearch(exerciseRepository, page: 1, pages: 1, exercises: const [_exercise12]);
    await cubit.initialize();
    when(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    ).thenAnswer((_) async => Result.success(_session(swappedExerciseId: 12)));

    cubit.selectExercise(_exercise12.id);
    verifyNever(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    );
    final result = await cubit.swapSelected();

    expect(cubit.state.selectedExerciseId, 12);
    expect(result?.exercise, _exercise12);
    expect(result?.session.id, 228);
    expect(result?.isConfirmed, isTrue);
    expect(cubit.state.error, isNull);
  });

  test('keeps the search open when PATCH response does not confirm the selected id', () async {
    _stubSearch(exerciseRepository, page: 1, pages: 1, exercises: const [_exercise12]);
    await cubit.initialize();
    when(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    ).thenAnswer((_) async => Result.success(_session(swappedExerciseId: 13)));

    cubit.selectExercise(_exercise12.id);
    final result = await cubit.swapSelected();

    expect(result, isNull);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.isSwapping, isFalse);
    expect(cubit.state.selectedExerciseId, 12);
  });

  test('reconciles an ambiguous PATCH through the workout session response', () async {
    _stubSearch(exerciseRepository, page: 1, pages: 1, exercises: const [_exercise12]);
    await cubit.initialize();
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/workout-exercise-sessions/228/swap'),
      type: DioExceptionType.receiveTimeout,
    );
    when(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    ).thenAnswer(
      (_) async => Result.error(AppNetworkException('timeout', originalError: timeout)),
    );
    when(() => workoutRepository.getWorkoutSessionDetails(172)).thenAnswer(
      (_) async => Result.success(
        WorkoutSessionDetailsDTO(
          id: 172,
          workoutProgramDayId: 25,
          duration: 0,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
          workoutSessions: [_sessionDto(swappedExerciseId: 12)],
        ),
      ),
    );

    cubit.selectExercise(_exercise12.id);
    final result = await cubit.swapSelected();

    expect(result?.isConfirmed, isTrue);
    verify(() => workoutRepository.getWorkoutSessionDetails(172)).called(1);
  });
}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockWorkoutSessionRepository extends Mock implements WorkoutSessionRepository {}

void _stubSearch(
  _MockExerciseSessionRepository repository, {
  required int page,
  required int pages,
  required List<ExerciseDetailsEntity> exercises,
}) {
  when(
    () => repository.searchSwapExercises(
      search: null,
      factionId: null,
      page: page,
      limit: ExerciseSwapCubit.pageLimit,
    ),
  ).thenAnswer((_) async => _searchResult(page: page, pages: pages, exercises: exercises));
}

Result<SwapExerciseSearchPage> _searchResult({
  required List<ExerciseDetailsEntity> exercises,
  int page = 1,
  int pages = 1,
}) {
  return Result.success((
    exercises: exercises,
    pagination: PaginationInfo(page: page, total: exercises.length, limit: 20, pages: pages),
  ));
}

WorkoutExerciseSessionEntity _session({required int swappedExerciseId}) {
  return WorkoutExerciseSessionEntity(
    id: 228,
    exerciseId: 33,
    workoutSessionId: 172,
    workoutProgramExerciseId: 100,
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

WorkoutExerciseSessionDTO _sessionDto({required int swappedExerciseId}) {
  return WorkoutExerciseSessionDTO(
    id: 228,
    exerciseId: 33,
    workoutSessionId: 172,
    workoutProgramExerciseId: 100,
    isSwapped: true,
    swappedExerciseId: swappedExerciseId,
  );
}

const _requestContext = ExerciseSwapRequestContext(
  workoutSessionId: 172,
  workoutExerciseSessionId: 228,
  currentExerciseId: 33,
  measurementSystem: MeasurementSystem.metric,
);

const _currentExercise = ExerciseDetailsEntity(
  id: 33,
  name: 'Current',
  description: 'Current',
  key: null,
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _exercise12 = ExerciseDetailsEntity(
  id: 12,
  name: 'Frog Stretch',
  description: 'Stretch',
  key: null,
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _exercise13 = ExerciseDetailsEntity(
  id: 13,
  name: 'Cobra Pose',
  description: 'Stretch',
  key: null,
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);
