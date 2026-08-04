import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_source.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

part 'workout_session_flow_cubit.freezed.dart';
part 'workout_session_flow_state.dart';

/// Manages the state of an active workout session.
///
/// Responsibilities:
/// - Starting / ending a workout session
/// - Exercise navigation (next / previous)
/// - Duration sync to local Drift cache
///
/// Restore logic (detecting interrupted sessions, prompting the user) lives in
/// WorkoutRestoreCubit. Use initFromRestore() to seed this cubit's state
/// after a successful restore.
@lazySingleton
class WorkoutSessionFlowCubit extends Cubit<WorkoutSessionFlowState> {
  WorkoutSessionFlowCubit(
    this._repository,
    this._exerciseSessionRepository,
    this._analytics,
    this._sessionCache,
    this._userSessionService,
  ) : super(const WorkoutSessionFlowState());

  final WorkoutSessionRepository _repository;
  final ExerciseSessionRepository _exerciseSessionRepository;
  final AnalyticsService _analytics;
  final WorkoutSessionCacheRepository _sessionCache;
  final UserSessionService _userSessionService;

  final Map<String, ActiveExerciseExecution> _exerciseExecutions = {};
  final Map<String, Future<Result<ActiveExerciseExecution>>> _pendingExerciseSessions = {};
  final Map<String, Exception> _exerciseSessionFailures = {};
  var _exerciseRegistryGeneration = 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Seeds this cubit with data from a restored interrupted session.
  /// Called by WorkoutRestoreCubit.restoreSession() after it has fetched all
  /// necessary data from the backend.
  void initFromRestore({
    required int sessionId,
    required ProgramDayEntity programDay,
    required int durationSec,
    required Map<int, List<WorkoutSet>> restoredSets,
    required int startIndex,
    Map<int, ActiveWorkoutExerciseContext> exerciseContexts = const {},
  }) {
    _clearExerciseRegistry();
    final executionPlan = WorkoutExecutionPlan.fromProgramDay(programDay);
    for (final spec in executionPlan.exercises) {
      final programExerciseId = spec.workoutProgramExerciseId;
      final context = programExerciseId == null ? null : exerciseContexts[programExerciseId];
      if (context == null) continue;
      _exerciseExecutions[spec.executionKey] = ActiveExerciseExecution(
        spec: spec,
        workoutSessionId: sessionId,
        session: context.session,
      );
    }
    final newState = state.copyWith(
      isLoading: false,
      executionPlan: executionPlan,
      startIntent: WorkoutStartIntent.program,
      programDay: programDay,
      workoutSessionId: sessionId,
      sessionStatus: WorkoutSessionStatus.active,
      isRestoredSession: true,
      restoredDurationSec: durationSec,
      restoredSets: restoredSets,
      currentExerciseIndex: startIndex,
      summary: null,
      error: null,
    );
    logger.d(newState);
    emit(newState);
  }

  ActiveExerciseExecution? exerciseExecutionFor(String executionKey) {
    return _exerciseExecutions[executionKey];
  }

  bool updateExerciseExecutionAfterSwap(ActiveExerciseExecution execution) {
    final executionKey = execution.spec.executionKey;
    final current = _exerciseExecutions[executionKey];
    if (current == null ||
        current.exerciseSessionId != execution.exerciseSessionId ||
        execution.workoutSessionId != state.workoutSessionId ||
        !state.isActive) {
      logger.w('WorkoutSessionFlowCubit: rejected a stale exercise swap context');
      return false;
    }

    _exerciseExecutions[executionKey] = execution;
    return true;
  }

  Future<Result<ActiveExerciseExecution>> ensureExerciseSession(WorkoutExerciseSpec spec) {
    final executionKey = spec.executionKey;
    final existing = _exerciseExecutions[executionKey];
    if (existing != null) return Future.value(Result.success(existing));

    final previousFailure = _exerciseSessionFailures[executionKey];
    if (previousFailure != null) return Future.value(Result.error(previousFailure));

    final pending = _pendingExerciseSessions[executionKey];
    if (pending != null) return pending;

    final workoutSessionId = state.workoutSessionId;
    if (workoutSessionId == null || !state.isActive) {
      return Future.value(Result.error(AppException('Cannot create exercise session without an active workout')));
    }

    final generation = _exerciseRegistryGeneration;
    late final Future<Result<ActiveExerciseExecution>> request;
    request =
        _createExerciseContext(
          spec: spec,
          workoutSessionId: workoutSessionId,
          generation: generation,
        ).whenComplete(() {
          if (identical(_pendingExerciseSessions[executionKey], request)) {
            final _ = _pendingExerciseSessions.remove(executionKey);
          }
        });
    _pendingExerciseSessions[executionKey] = request;
    return request;
  }

  Future<Result<ActiveExerciseExecution>> retryEnsureExerciseSession(WorkoutExerciseSpec spec) {
    _exerciseSessionFailures.remove(spec.executionKey);
    return ensureExerciseSession(spec);
  }

  void prepareProgramWorkout(ProgramDayEntity programDay) {
    prepareWorkout(
      WorkoutExecutionPlan.fromProgramDay(programDay),
      intent: WorkoutStartIntent.program,
      programDay: programDay,
    );
  }

  void prepareWorkout(
    WorkoutExecutionPlan plan, {
    required WorkoutStartIntent intent,
    ProgramDayEntity? programDay,
  }) {
    if (state.isStartingWorkout || state.isActive) return;
    _clearExerciseRegistry();
    emit(
      state.copyWith(
        executionPlan: plan,
        startIntent: intent,
        programDay: programDay,
        workoutSessionId: null,
        currentExerciseIndex: 0,
        sessionStatus: null,
        isStartingWorkout: false,
        isRestoredSession: false,
        restoredDurationSec: 0,
        restoredSets: const {},
        summary: null,
        error: null,
      ),
    );
  }

  Future<Result<ActiveExerciseExecution>> startProgramWorkout(ProgramDayEntity programDay) {
    prepareProgramWorkout(programDay);
    return startPreparedWorkout();
  }

  Future<Result<ActiveExerciseExecution>> startAdHocWorkout(WorkoutExecutionPlan plan) {
    if (plan.source is! AdHocWorkoutSource) {
      return Future.value(Result.error(AppException('Ad-hoc workout requires an ad-hoc execution plan')));
    }
    prepareWorkout(plan, intent: WorkoutStartIntent.freeRun);
    return startPreparedWorkout();
  }

  /// Compatibility entry point for the current program details UI.
  Future<void> startWorkout(ProgramDayEntity programDay) async {
    await startProgramWorkout(programDay);
  }

  /// Creates the backend workout and its first exercise session in order.
  /// The prepared plan survives the readiness quiz; no backend session exists
  /// until this method is called.
  Future<Result<ActiveExerciseExecution>> startPreparedWorkout() async {
    final plan = state.executionPlan;
    if (plan == null || plan.exercises.isEmpty) {
      return Result.error(AppException('Cannot start workout without a prepared execution plan'));
    }
    if (state.isStartingWorkout) {
      return Result.error(AppException('Workout start is already in progress'));
    }
    if (state.isActive && state.workoutSessionId != null) {
      return ensureExerciseSession(plan.exercises[state.currentExerciseIndex]);
    }

    final generation = _exerciseRegistryGeneration;
    emit(state.copyWith(isStartingWorkout: true, summary: null, error: null));

    final result = switch (plan.source) {
      ProgramWorkoutSource(:final programDayId) => await _repository.startWorkoutSession(programDayId),
      AdHocWorkoutSource() => await _repository.startAdHocWorkoutSession(),
    };

    switch (result) {
      case Success(value: final sessionData):
        if (generation != _exerciseRegistryGeneration || !identical(state.executionPlan, plan)) {
          return Result.error(AppException('Prepared workout changed while starting session'));
        }
        unawaited(_analytics.logEvent(AnalyticsEvents.workoutStart));
        logger.d('WorkoutSessionFlowCubit: started session ${sessionData.id}');

        if (plan.source case ProgramWorkoutSource(:final programDayId)) {
          unawaited(
            _sessionCache.saveActiveSession(
              remoteSessionId: sessionData.id,
              programDayId: programDayId,
            ),
          );
        }

        emit(
          state.copyWith(
            workoutSessionId: sessionData.id,
            sessionStatus: WorkoutSessionStatus.active,
            isRestoredSession: false,
            restoredDurationSec: 0,
            restoredSets: const {},
          ),
        );

        final firstExecution = await ensureExerciseSession(plan.exercises.first);
        if (generation != _exerciseRegistryGeneration || state.workoutSessionId != sessionData.id) {
          return Result.error(AppException('Workout session changed while initializing first exercise'));
        }
        emit(
          state.copyWith(
            isStartingWorkout: false,
            error: firstExecution.isError ? 'Failed to start first exercise' : null,
          ),
        );
        return firstExecution;

      case Failure(:final error):
        emit(
          state.copyWith(
            isStartingWorkout: false,
            error: 'Failed to start workout: $error',
          ),
        );
        return Result.error(error);
    }
  }

  /// Advances to the next exercise, or finishes the session if on the last one.
  Future<void> nextExercise(int workoutSessionDuration) async {
    final nextIndex = state.currentExerciseIndex + 1;

    unawaited(_sessionCache.updateDuration(workoutSessionDuration));
    unawaited(_sessionCache.updateLastExerciseIndex(state.currentExerciseIndex));

    if (nextIndex < state.totalExercises) {
      emit(state.copyWith(currentExerciseIndex: nextIndex));
    } else {
      await _finishWorkout(WorkoutSessionStatus.completed, workoutSessionDuration);
    }
  }

  /// Moves back to the previous exercise.
  void previousExercise() {
    if (state.isFirstExercise) return;
    emit(state.copyWith(currentExerciseIndex: state.currentExerciseIndex - 1));
  }

  /// Persists the current elapsed duration to Drift.
  /// Called periodically by ActiveWorkoutShell every ~10 seconds.
  void syncDuration(int elapsedSeconds) {
    unawaited(_sessionCache.updateDuration(elapsedSeconds));
  }

  /// Cancels the current active session.
  Future<void> cancelWorkout(int workoutSessionDuration) async {
    if (state.isFinished) return;
    await _finishWorkout(WorkoutSessionStatus.canceled, workoutSessionDuration);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _finishWorkout(WorkoutSessionStatus status, int workoutSessionDuration) async {
    final workoutSessionId = state.workoutSessionId;

    if (workoutSessionId == null) {
      _clearExerciseRegistry();
      emit(state.copyWith(sessionStatus: status, isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.endWorkoutSession(
      status: status,
      workoutSessionId: workoutSessionId,
      workoutSessionDuration: workoutSessionDuration,
    );

    switch (result) {
      case Success(value: final summary):
        if (status == WorkoutSessionStatus.completed) {
          unawaited(_analytics.logEvent(AnalyticsEvents.workoutComplete));
          if (summary.isLevelUp && summary.currentLevel != null) {
            unawaited(
              _analytics.logEvent(AnalyticsEvents.workoutLevelUp, {'level': summary.currentLevel}),
            );
          }
        } else if (status == WorkoutSessionStatus.canceled) {
          unawaited(_analytics.logEvent(AnalyticsEvents.workoutCancel));
        }
        unawaited(_sessionCache.clearActiveSession());
        emit(state.copyWith(sessionStatus: status, summary: summary, isLoading: false));

      case Failure(:final error):
        emit(
          state.copyWith(
            sessionStatus: status,
            error: 'Failed to end workout: $error',
            isLoading: false,
          ),
        );
    }
    _clearExerciseRegistry();
  }

  Future<Result<ActiveExerciseExecution>> _createExerciseContext({
    required WorkoutExerciseSpec spec,
    required int workoutSessionId,
    required int generation,
  }) async {
    final result = await _exerciseSessionRepository.createWorkoutExerciseSession(
      exerciseId: spec.exerciseId,
      workoutSessionId: workoutSessionId,
      workoutProgramExerciseId: spec.workoutProgramExerciseId,
      system: _measurementSystem,
    );

    switch (result) {
      case Success(value: final session):
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while creating exercise session'));
        }
        final execution = _buildExecution(spec, workoutSessionId, session);
        _exerciseExecutions[spec.executionKey] = execution;
        return Result.success(execution);

      case Failure(:final error):
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while creating exercise session'));
        }
        if (_isAmbiguousCreateFailure(error)) {
          final reconciled = await _reconcileExerciseContext(
            spec: spec,
            workoutSessionId: workoutSessionId,
            generation: generation,
          );
          if (reconciled != null) return Result.success(reconciled);
        }
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while reconciling exercise session'));
        }
        _exerciseSessionFailures[spec.executionKey] = error;
        return Result.error(error);
    }
  }

  Future<ActiveExerciseExecution?> _reconcileExerciseContext({
    required WorkoutExerciseSpec spec,
    required int workoutSessionId,
    required int generation,
  }) async {
    final result = await _repository.getWorkoutSessionDetails(workoutSessionId);
    if (result case Success(value: final details?)) {
      final programExerciseId = spec.workoutProgramExerciseId;
      final dto = programExerciseId == null
          ? _selectUnboundSession(details, spec)
          : details.exerciseSessionsByProgramExerciseId[programExerciseId];
      if (dto == null || !_isCurrentRegistry(generation, workoutSessionId)) return null;

      final execution = _buildExecution(
        spec,
        workoutSessionId,
        dto.toEntity(_measurementSystem),
      );
      _exerciseExecutions[spec.executionKey] = execution;
      return execution;
    }
    return null;
  }

  WorkoutExerciseSessionDTO? _selectUnboundSession(
    WorkoutSessionDetailsDTO details,
    WorkoutExerciseSpec spec,
  ) {
    final candidates = details.normalizedExerciseSessions
        .where(
          (session) =>
              session.workoutProgramExerciseId == null && session.exerciseId == spec.exerciseId && session.isActive,
        )
        .toList();
    if (candidates.length == 1) return candidates.single;
    if (candidates.length > 1) {
      logger.w(
        'WorkoutSessionFlowCubit: multiple active unbound exercise sessions found for ${spec.executionKey}',
      );
    }
    return null;
  }

  ActiveExerciseExecution _buildExecution(
    WorkoutExerciseSpec spec,
    int workoutSessionId,
    WorkoutExerciseSessionEntity session,
  ) {
    return ActiveExerciseExecution(
      spec: spec,
      workoutSessionId: workoutSessionId,
      session: session,
    );
  }

  bool _isCurrentRegistry(int generation, int workoutSessionId) {
    return generation == _exerciseRegistryGeneration && state.workoutSessionId == workoutSessionId;
  }

  bool _isAmbiguousCreateFailure(Exception error) {
    if (error is! AppNetworkException) return false;
    if ((error.statusCode ?? 0) >= 500) return true;

    final original = error.originalError;
    if (original is! DioException) return error.statusCode == null;
    return switch (original.type) {
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.unknown => true,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.badCertificate ||
      DioExceptionType.badResponse ||
      DioExceptionType.cancel => false,
    };
  }

  MeasurementSystem get _measurementSystem {
    return _userSessionService.currentUser?.map(
          newUser: (_) => null,
          onboarded: (user) => user.measurementSystem,
        ) ??
        MeasurementSystem.metric;
  }

  void _clearExerciseRegistry() {
    _exerciseRegistryGeneration++;
    _exerciseExecutions.clear();
    _pendingExerciseSessions.clear();
    _exerciseSessionFailures.clear();
  }
}
