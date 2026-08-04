import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
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
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
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

  setUpAll(() {
    registerFallbackValue(CachedWorkoutSource.program);
    registerFallbackValue(WorkoutInitializationPhase.workoutCreated);
  });

  setUp(() {
    workoutRepository = _MockWorkoutSessionRepository();
    exerciseRepository = _MockExerciseSessionRepository();
    analytics = _MockAnalyticsService();
    sessionCache = _MockWorkoutSessionCacheRepository();
    userSessionService = _MockUserSessionService();
    when(() => userSessionService.currentUser).thenReturn(_user());
    when(
      () => sessionCache.saveActiveSession(
        remoteSessionId: any(named: 'remoteSessionId'),
        programDayId: any(named: 'programDayId'),
        source: any(named: 'source'),
        executionPlanJson: any(named: 'executionPlanJson'),
        initializationPhase: any(named: 'initializationPhase'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => sessionCache.saveExerciseSession(
        workoutSessionId: any(named: 'workoutSessionId'),
        executionKey: any(named: 'executionKey'),
        exerciseId: any(named: 'exerciseId'),
        effectiveExerciseId: any(named: 'effectiveExerciseId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        position: any(named: 'position'),
        workoutProgramExerciseId: any(named: 'workoutProgramExerciseId'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => sessionCache.updateInitializationPhase(any()),
    ).thenAnswer((_) async {});
    when(() => analytics.logEvent(any())).thenAnswer((_) async {});
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
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

      final first = cubit.ensureExerciseSession(cubit.state.currentExercise!);
      final second = cubit.ensureExerciseSession(cubit.state.currentExercise!);

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

      final repeated = await cubit.ensureExerciseSession(cubit.state.currentExercise!);
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

      final failed = await cubit.ensureExerciseSession(cubit.state.currentExercise!);
      final rebuild = await cubit.ensureExerciseSession(cubit.state.currentExercise!);

      expect(failed.isError, isTrue);
      expect(rebuild.isError, isTrue);
      expect(attempts, 1);

      final retried = await cubit.retryEnsureExerciseSession(cubit.state.currentExercise!);
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

      final result = await cubit.ensureExerciseSession(cubit.state.currentExercise!);

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

      final result = await cubit.ensureExerciseSession(cubit.state.currentExercise!);

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
      final current = _execution(cubit)!;
      final updated = ActiveExerciseExecution(
        spec: current.spec,
        workoutSessionId: current.workoutSessionId,
        session: _session(id: 225, swappedExerciseId: 12),
        effectiveExercise: _replacementExercise,
      );

      expect(cubit.updateExerciseExecutionAfterSwap(updated), isTrue);
      expect(_execution(cubit)?.effectiveExercise.id, 12);
      expect(_execution(cubit)?.session.swappedExerciseId, 12);

      final stale = ActiveExerciseExecution(
        spec: current.spec,
        workoutSessionId: current.workoutSessionId,
        session: _session(id: 999, swappedExerciseId: 13),
        effectiveExercise: _replacementExercise,
      );
      expect(cubit.updateExerciseExecutionAfterSwap(stale), isFalse);
      expect(_execution(cubit)?.session.id, 225);
    });

    test('does not start a second workout while one is active', () async {
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});

      final result = await cubit.startProgramWorkout(_programDay);

      expect(result.orNull?.exerciseSessionId, 225);
      expect(cubit.state.workoutSessionId, 169);
      verifyNever(() => workoutRepository.startWorkoutSession(any()));
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
      final pending = cubit.ensureExerciseSession(cubit.state.currentExercise!);

      _seedActiveWorkout(cubit, sessionId: 170);
      completer.complete(Result.success(_session(id: 222)));
      final staleResult = await pending;

      expect(staleResult.isError, isTrue);
      expect(_execution(cubit), isNull);
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

      expect(_execution(cubit), isNull);
      expect(cubit.state.isCanceled, isTrue);
    });

    test('keeps the active session and registry when cancellation fails', () async {
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      when(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.canceled,
          workoutSessionId: 169,
          workoutSessionDuration: 15,
        ),
      ).thenAnswer((_) async => Result.error(Exception('cancel failed')));

      await cubit.cancelWorkout(15);

      expect(cubit.state.isActive, isTrue);
      expect(cubit.state.error, contains('cancel failed'));
      expect(_execution(cubit)?.exerciseSessionId, 225);
      verifyNever(() => sessionCache.clearActiveSession());
    });
  });

  group('prepared workout lifecycle', () {
    test('prepares a program workout without creating backend sessions', () {
      cubit.prepareProgramWorkout(_programDay);

      expect(cubit.state.isPrepared, isTrue);
      expect(cubit.state.currentExercise?.exerciseId, 33);
      expect(cubit.state.currentExercise?.workoutProgramExerciseId, 100);
      expect(cubit.state.totalExercises, 1);
      verifyZeroInteractions(workoutRepository);
      verifyZeroInteractions(exerciseRepository);
    });

    test('starts a program workout before its first exercise session', () async {
      final calls = <String>[];
      when(() => workoutRepository.startWorkoutSession(25)).thenAnswer((_) async {
        calls.add('workout');
        return const Result.success(_programWorkoutSession);
      });
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 33,
          workoutSessionId: 170,
          workoutProgramExerciseId: 100,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async {
        calls.add('exercise');
        return Result.success(_session(id: 226, workoutSessionId: 170));
      });
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});
      when(
        () => sessionCache.saveActiveSession(remoteSessionId: 170, programDayId: 25),
      ).thenAnswer((_) async {});

      final result = await cubit.startProgramWorkout(_programDay);

      expect(calls, ['workout', 'exercise']);
      expect(result.orNull?.exerciseSessionId, 226);
      expect(result.orNull?.spec.workoutProgramExerciseId, 100);
      expect(cubit.state.isActive, isTrue);
      expect(cubit.state.isStartingWorkout, isFalse);
    });

    test('starts Free Run without program bindings and persists its ad-hoc plan', () async {
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:one',
      );
      when(() => workoutRepository.startAdHocWorkoutSession()).thenAnswer(
        (_) async => const Result.success(_freeWorkoutSession),
      );
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async => Result.success(_freeSession(id: 246)));
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});

      final result = await cubit.startAdHocWorkout(plan);

      expect(result.orNull?.spec.executionKey, 'free-run:one');
      expect(result.orNull?.exerciseSessionId, 246);
      expect(result.orNull?.spec.workoutProgramExerciseId, isNull);
      expect(cubit.state.programDay, isNull);
      expect(cubit.state.startIntent, WorkoutStartIntent.freeRun);
      verify(
        () => sessionCache.saveActiveSession(
          remoteSessionId: 182,
          source: CachedWorkoutSource.adHoc,
          executionPlanJson: any(named: 'executionPlanJson'),
        ),
      ).called(1);
    });

    test('keeps a prepared Free Run retryable when workout creation fails', () async {
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:create-failure',
      );
      when(
        () => workoutRepository.startAdHocWorkoutSession(),
      ).thenAnswer((_) async => Result.error(Exception('offline')));

      final result = await cubit.startAdHocWorkout(plan);

      expect(result.isError, isTrue);
      expect(cubit.state.isPrepared, isTrue);
      expect(cubit.state.workoutSessionId, isNull);
      expect(cubit.state.isStartingWorkout, isFalse);
      expect(cubit.state.error, contains('offline'));
      verifyZeroInteractions(exerciseRepository);
      verify(
        () => analytics.logEvent(
          AnalyticsEvents.workoutMutationFailure,
          any(),
        ),
      ).called(1);
    });

    test('retries the first Free Run exercise after the workout session was created', () async {
      var exerciseAttempts = 0;
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:retry',
      );
      when(() => workoutRepository.startAdHocWorkoutSession()).thenAnswer(
        (_) async => const Result.success(_freeWorkoutSession),
      );
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async {
        exerciseAttempts++;
        return exerciseAttempts == 1
            ? Result.error(Exception('exercise create failed'))
            : Result.success(_freeSession(id: 247));
      });
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});

      cubit.prepareWorkout(plan, intent: WorkoutStartIntent.freeRun);

      final first = await cubit.startPreparedWorkout();
      final retry = await cubit.startPreparedWorkout();

      expect(first.isError, isTrue);
      expect(retry.orNull?.exerciseSessionId, 247);
      expect(exerciseAttempts, 2);
      expect(cubit.state.isStartingWorkout, isFalse);
      expect(cubit.state.error, isNull);
      verify(() => workoutRepository.startAdHocWorkoutSession()).called(1);
    });

    test('completes one-exercise Free Run through the common next path', () async {
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:complete',
      );
      when(() => workoutRepository.startAdHocWorkoutSession()).thenAnswer(
        (_) async => const Result.success(_freeWorkoutSession),
      );
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async => Result.success(_freeSession(id: 246)));
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});
      when(() => sessionCache.updateDuration(60)).thenAnswer((_) async {});
      when(() => sessionCache.updateLastExerciseIndex(0)).thenAnswer((_) async {});
      when(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.completed,
          workoutSessionId: 182,
          workoutSessionDuration: 60,
        ),
      ).thenAnswer((_) async => const Result.success(_summary));
      when(() => sessionCache.clearActiveSession()).thenAnswer((_) async {});

      await cubit.startAdHocWorkout(plan);
      await cubit.nextExercise(60);

      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.summary, _summary);
    });

    test('keeps completion retryable after a network failure', () async {
      var attempts = 0;
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      when(() => sessionCache.updateDuration(60)).thenAnswer((_) async {});
      when(() => sessionCache.updateLastExerciseIndex(0)).thenAnswer((_) async {});
      when(() => sessionCache.clearActiveSession()).thenAnswer((_) async {});
      when(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.completed,
          workoutSessionId: 169,
          workoutSessionDuration: 60,
        ),
      ).thenAnswer((_) async {
        attempts++;
        return attempts == 1 ? Result.error(Exception('completion offline')) : const Result.success(_summary);
      });

      await cubit.nextExercise(60);

      expect(cubit.state.isActive, isTrue);
      expect(cubit.state.summary, isNull);
      expect(cubit.state.error, contains('completion offline'));
      verifyNever(() => sessionCache.clearActiveSession());

      await cubit.nextExercise(60);

      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.error, isNull);
      expect(attempts, 2);
      verify(() => sessionCache.clearActiveSession()).called(1);
    });

    test('coalesces concurrent terminal mutations', () async {
      final completer = Completer<Result<WorkoutSessionSummaryEntity>>();
      _seedActiveWorkout(cubit, contexts: {100: _context(sessionId: 225)});
      when(() => sessionCache.updateDuration(60)).thenAnswer((_) async {});
      when(() => sessionCache.updateLastExerciseIndex(0)).thenAnswer((_) async {});
      when(() => sessionCache.clearActiveSession()).thenAnswer((_) async {});
      when(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.completed,
          workoutSessionId: 169,
          workoutSessionDuration: 60,
        ),
      ).thenAnswer((_) => completer.future);

      final first = cubit.nextExercise(60);
      final second = cubit.nextExercise(60);

      verify(
        () => workoutRepository.endWorkoutSession(
          status: WorkoutSessionStatus.completed,
          workoutSessionId: 169,
          workoutSessionDuration: 60,
        ),
      ).called(1);

      completer.complete(const Result.success(_summary));
      await Future.wait([first, second]);

      expect(cubit.state.isCompleted, isTrue);
      verify(() => sessionCache.clearActiveSession()).called(1);
    });

    test('coalesces repeated start taps while workout creation is in flight', () async {
      final completer = Completer<Result<WorkoutSession>>();
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:tap',
      );
      cubit.prepareWorkout(plan, intent: WorkoutStartIntent.freeRun);
      when(() => workoutRepository.startAdHocWorkoutSession()).thenAnswer((_) => completer.future);
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer((_) async => Result.success(_freeSession(id: 246)));
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});

      final first = cubit.startPreparedWorkout();
      final repeated = await cubit.startPreparedWorkout();
      expect(repeated.isError, isTrue);

      completer.complete(const Result.success(_freeWorkoutSession));
      expect((await first).isSuccess, isTrue);
      verify(() => workoutRepository.startAdHocWorkoutSession()).called(1);
    });

    test('reconciles an ambiguous Free Run exercise POST through workout GET', () async {
      final plan = WorkoutExecutionPlan.freeRun(
        details: _freeRunningExercise,
        executionKey: 'free-run:timeout',
      );
      final timeout = DioException(
        requestOptions: RequestOptions(path: '/workout-exercise-sessions'),
        type: DioExceptionType.receiveTimeout,
      );
      when(() => workoutRepository.startAdHocWorkoutSession()).thenAnswer(
        (_) async => const Result.success(_freeWorkoutSession),
      );
      when(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).thenAnswer(
        (_) async => Result.error(AppNetworkException('timeout', originalError: timeout)),
      );
      when(() => workoutRepository.getWorkoutSessionDetails(182)).thenAnswer(
        (_) async => Result.success(
          WorkoutSessionDetailsDTO(
            id: 182,
            duration: 0,
            status: WorkoutSessionStatus.active,
            totalXpEarned: 0,
            exerciseSessions: [_freeSessionDto(id: 246)],
          ),
        ),
      );
      when(() => analytics.logEvent(any())).thenAnswer((_) async {});

      final result = await cubit.startAdHocWorkout(plan);

      expect(result.orNull?.exerciseSessionId, 246);
      verify(
        () => analytics.logEvent(
          AnalyticsEvents.workoutExerciseReconciled,
          any(),
        ),
      ).called(1);
      verify(() => workoutRepository.getWorkoutSessionDetails(182)).called(1);
      verify(
        () => exerciseRepository.createWorkoutExerciseSession(
          exerciseId: 4,
          workoutSessionId: 182,
          system: MeasurementSystem.metric,
        ),
      ).called(1);
    });
  });
}

void _seedActiveWorkout(
  WorkoutSessionFlowCubit cubit, {
  int sessionId = 169,
  Map<int, ActiveWorkoutExerciseContext> contexts = const {},
}) {
  cubit.initFromRestore(
    sessionId: sessionId,
    programDay: _programDay,
    durationSec: 0,
    restoredSets: const {},
    startIndex: 0,
    exerciseContexts: contexts,
  );
}

ActiveExerciseExecution? _execution(WorkoutSessionFlowCubit cubit) {
  final executionKey = cubit.state.executionPlan?.exercises.first.executionKey;
  return executionKey == null ? null : cubit.exerciseExecutionFor(executionKey);
}

ActiveWorkoutExerciseContext _context({required int sessionId}) {
  return ActiveWorkoutExerciseContext(
    programExercise: _programExercise,
    session: _session(id: sessionId),
    effectiveExercise: _exerciseDetails,
  );
}

WorkoutExerciseSessionEntity _session({
  required int id,
  int workoutSessionId = 169,
  int? swappedExerciseId,
}) {
  return WorkoutExerciseSessionEntity(
    id: id,
    exerciseId: 33,
    workoutSessionId: workoutSessionId,
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

WorkoutExerciseSessionEntity _freeSession({required int id}) {
  return WorkoutExerciseSessionEntity(
    id: id,
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
    sets: const [],
    exercise: null,
    swappedExercise: null,
  );
}

WorkoutExerciseSessionDTO _freeSessionDto({required int id}) {
  return WorkoutExerciseSessionDTO(
    id: id,
    exerciseId: 4,
    workoutSessionId: 182,
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

const _freeRunningExercise = ExerciseDetailsEntity(
  id: 4,
  name: 'Running',
  description: 'Run',
  key: null,
  factionId: 3,
  metrics: [WorkoutMetric.time, WorkoutMetric.distance],
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

const _programWorkoutSession = WorkoutSession(
  id: 170,
  userId: 67,
  workoutProgramDayId: 25,
  duration: 0,
  status: WorkoutSessionStatus.active,
  totalXpEarned: 0,
);

const _freeWorkoutSession = WorkoutSession(
  id: 182,
  userId: 67,
  duration: 0,
  status: WorkoutSessionStatus.active,
  totalXpEarned: 0,
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
