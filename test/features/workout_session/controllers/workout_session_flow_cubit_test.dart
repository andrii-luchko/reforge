import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

class _MockWorkoutSessionRepository extends Mock implements WorkoutSessionRepository {}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockWorkoutSessionCacheRepository extends Mock implements WorkoutSessionCacheRepository {}

class _MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late _MockWorkoutSessionRepository workoutRepository;
  late _MockExerciseSessionRepository exerciseRepository;
  late _MockAnalyticsService analytics;
  late _MockWorkoutSessionCacheRepository sessionCache;
  late _MockUserSessionService userSessionService;
  late WorkoutSessionFlowCubit cubit;

  setUp(() {
    workoutRepository = _MockWorkoutSessionRepository();
    exerciseRepository = _MockExerciseSessionRepository();
    analytics = _MockAnalyticsService();
    sessionCache = _MockWorkoutSessionCacheRepository();
    userSessionService = _MockUserSessionService();
    when(() => userSessionService.currentUser).thenReturn(_user());
    cubit = WorkoutSessionFlowCubit(
      workoutRepository,
      exerciseRepository,
      analytics,
      sessionCache,
      userSessionService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('exercise session registry', () {
    test('coalesces concurrent ensure calls and reuses the registered context', () async {
      final completer = Completer<Result<WorkoutExerciseSessionEntity>>();
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) => completer.future);
      _seedActiveWorkout(cubit);

      final first = cubit.ensureExerciseSession(_programExercise);
      final second = cubit.ensureExerciseSession(_programExercise);

      expect(identical(first, second), isTrue);
      verify(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).called(1);

      completer.complete(Result.success(_session(id: 222)));
      final contexts = await Future.wait([first, second]);

      expect(contexts.first.orNull?.session.id, 222);
      expect(contexts.last.orNull?.session.id, 222);

      final repeated = await cubit.ensureExerciseSession(_programExercise);
      expect(repeated.orNull?.session.id, 222);
      verifyNoMoreInteractions(exerciseRepository);
    });

    test('does not repeat a failed POST until explicit retry', () async {
      var attempts = 0;
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async {
        attempts++;
        return attempts == 1 ? Result.error(Exception('create failed')) : Result.success(_session(id: 223));
      });
      _seedActiveWorkout(cubit);

      final failed = await cubit.ensureExerciseSession(_programExercise);
      final rebuild = await cubit.ensureExerciseSession(_programExercise);

      expect(failed.isError, isTrue);
      expect(rebuild.isError, isTrue);
      expect(attempts, 1);

      final retried = await cubit.retryEnsureExerciseSession(_programExercise);
      expect(retried.orNull?.session.id, 223);
      expect(attempts, 2);
    });

    test('reconciles an ambiguous POST through workout session details', () async {
      final requestOptions = RequestOptions(path: '/workout-exercise-sessions');
      final timeout = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.receiveTimeout,
      );
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer(
        (_) async => Result.error(AppNetworkException('timeout', originalError: timeout)),
      );
      when(() => workoutRepository.getWorkoutSessionDetails(169)).thenAnswer(
        (_) async => Result.success(
          WorkoutSessionDetailsDTO(
            id: 169,
            workoutProgramDayId: 25,
            duration: 0,
            status: WorkoutSessionStatus.active,
            totalXpEarned: 0,
            workoutSessions: [_sessionDto(id: 224)],
          ),
        ),
      );
      _seedActiveWorkout(cubit);

      final result = await cubit.ensureExerciseSession(_programExercise);

      expect(result.isSuccess, isTrue);
      expect(result.orNull?.session.id, 224);
      expect(result.orNull?.effectiveExercise.id, 33);
      verify(() => workoutRepository.getWorkoutSessionDetails(169)).called(1);
      verify(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).called(1);
    });

    test('uses a restored context without creating another session', () async {
      final restored = _context(sessionId: 225);
      _seedActiveWorkout(cubit, contexts: {100: restored});

      final result = await cubit.ensureExerciseSession(_programExercise);

      expect(result.orNull?.session.id, 225);
      verifyNever(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      );
    });

    test('updates the registered context after a confirmed swap and rejects a stale session id', () {
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      final updated = ActiveWorkoutExerciseContext(
        programExercise: _programExercise,
        session: _session(id: 225, swappedExerciseId: 12),
        effectiveExercise: _replacementExercise,
      );

      expect(cubit.updateExerciseContextAfterSwap(updated), isTrue);
      expect(cubit.exerciseContextFor(100)?.effectiveExercise.id, 12);
      expect(cubit.exerciseContextFor(100)?.session.swappedExerciseId, 12);

      final stale = ActiveWorkoutExerciseContext(
        programExercise: _programExercise,
        session: _session(id: 999, swappedExerciseId: 13),
        effectiveExercise: _replacementExercise,
      );
      expect(cubit.updateExerciseContextAfterSwap(stale), isFalse);
      expect(cubit.exerciseContextFor(100)?.session.id, 225);
    });

    test('clears restored contexts when a new workout starts', () async {
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      when(() => workoutRepository.startWorkoutSession(25)).thenAnswer(
        (_) async => const Result.success(
          WorkoutSession(
            id: 170,
            userId: 67,
            workoutProgramDayId: 25,
            duration: 0,
            status: WorkoutSessionStatus.active,
            totalXpEarned: 0,
          ),
        ),
      );
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});
      when(
        () => sessionCache.saveActiveSession(remoteSessionId: 170, programDayId: 25),
      ).thenAnswer((_) async {});

      await cubit.startWorkout(_programDay);

      expect(cubit.exerciseContextFor(100), isNull);
      expect(cubit.state.workoutSessionId, 170);
    });

    test('ignores a stale POST response after a new workout starts', () async {
      final completer = Completer<Result<WorkoutExerciseSessionEntity>>();
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 169,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) => completer.future);
      _seedActiveWorkout(cubit);
      final pending = cubit.ensureExerciseSession(_programExercise);

      when(() => workoutRepository.startWorkoutSession(25)).thenAnswer(
        (_) async => const Result.success(
          WorkoutSession(
            id: 170,
            userId: 67,
            workoutProgramDayId: 25,
            duration: 0,
            status: WorkoutSessionStatus.active,
            totalXpEarned: 0,
          ),
        ),
      );
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});
      when(
        () => sessionCache.saveActiveSession(remoteSessionId: 170, programDayId: 25),
      ).thenAnswer((_) async {});

      await cubit.startWorkout(_programDay);
      completer.complete(Result.success(_session(id: 222)));
      final staleResult = await pending;

      expect(staleResult.isError, isTrue);
      expect(cubit.exerciseContextFor(100), isNull);
      expect(cubit.state.workoutSessionId, 170);
    });

    test('clears contexts after workout cancellation', () async {
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      when(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.canceled,
          workoutSessionId: 169,
          workoutSessionDuration: 15,
        ),
      ).thenAnswer((_) async => const Result.success(_summary));
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});
      when(() => sessionCache.clearActiveSession()).thenAnswer((_) async {});

      await cubit.cancelWorkout(15);

      expect(cubit.exerciseContextFor(100), isNull);
      expect(cubit.state.isCanceled, isTrue);
    });
  });
}

void _seedActiveWorkout(
  WorkoutSessionFlowCubit cubit, {
  Map<int, ActiveWorkoutExerciseContext> contexts = const {},
}) {
  cubit.initFromRestore(
    sessionId: 169,
    programDay: _programDay,
    durationSec: 0,
    restoredSets: const {},
    startIndex: 0,
    exerciseContexts: contexts,
  );
}

ActiveWorkoutExerciseContext _context({required int sessionId}) {
  return ActiveWorkoutExerciseContext(
    programExercise: _programExercise,
    session: _session(id: sessionId),
    effectiveExercise: _exerciseDetails,
  );
}

WorkoutExerciseSessionEntity _session({required int id, int? swappedExerciseId}) {
  return WorkoutExerciseSessionEntity(
    id: id,
    exerciseId: 33,
    workoutSessionId: 169,
    workoutProgramExerciseId: 100,
    isSwapped: swappedExerciseId != null,
    swappedExerciseId: swappedExerciseId,
    isActive: true,
    notes: null,
    lastCompletedSet: null,
    createdAt: null,
    updatedAt: null,
    sets: const [],
    exercise: null,
    swappedExercise: null,
  );
}

WorkoutExerciseSessionDTO _sessionDto({required int id}) {
  return WorkoutExerciseSessionDTO(
    id: id,
    exerciseId: 33,
    workoutSessionId: 169,
    workoutProgramExerciseId: 100,
  );
}

const _exerciseDetails = ExerciseDetailsEntity(
  id: 33,
  name: 'Exercise',
  description: '',
  key: 'exercise',
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _replacementExercise = ExerciseDetailsEntity(
  id: 12,
  name: 'Replacement',
  description: '',
  key: null,
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _programExercise = ProgramExerciseEntity(
  id: 100,
  programDayId: 25,
  sets: 3,
  order: 1,
  exerciseDetails: _exerciseDetails,
  executionMode: ExecutionMode.standard,
  segments: [],
);

const _programDay = ProgramDayEntity(
  id: 25,
  name: 'Day 1',
  dayNumber: 1,
  programExercises: [_programExercise],
);

const _summary = WorkoutSessionSummaryEntity(
  id: 169,
  duration: 15,
  totalXpEarned: 0,
  earnedMilestones: [],
  isLevelUp: false,
  currentLevel: null,
);

User _user() {
  return User.onboarded(
    id: 67,
    measurementSystem: MeasurementSystem.metric,
    factionId: 1,
    birthDate: DateTime(1990),
    workoutsPerWeek: 3,
  );
}
