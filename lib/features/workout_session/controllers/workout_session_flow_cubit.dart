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
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
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

  final Map<int, ActiveWorkoutExerciseContext> _exerciseContexts = {};
  final Map<int, Future<Result<ActiveWorkoutExerciseContext>>> _pendingExerciseSessions = {};
  final Map<int, Exception> _exerciseSessionFailures = {};
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
    _exerciseContexts.addAll(exerciseContexts);
    final newState = state.copyWith(
      isLoading: false,
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

  ActiveWorkoutExerciseContext? exerciseContextFor(int workoutProgramExerciseId) {
    return _exerciseContexts[workoutProgramExerciseId];
  }

  bool updateExerciseContextAfterSwap(ActiveWorkoutExerciseContext context) {
    final programExerciseId = context.programExercise.id;
    final current = _exerciseContexts[programExerciseId];
    if (current == null ||
        current.session.id != context.session.id ||
        context.session.workoutSessionId != state.workoutSessionId ||
        !state.isActive) {
      logger.w('WorkoutSessionFlowCubit: rejected a stale exercise swap context');
      return false;
    }

    _exerciseContexts[programExerciseId] = context;
    return true;
  }

  Future<Result<ActiveWorkoutExerciseContext>> ensureExerciseSession(
    ProgramExerciseEntity programExercise,
  ) {
    final programExerciseId = programExercise.id;
    final existing = _exerciseContexts[programExerciseId];
    if (existing != null) return Future.value(Result.success(existing));

    final previousFailure = _exerciseSessionFailures[programExerciseId];
    if (previousFailure != null) return Future.value(Result.error(previousFailure));

    final pending = _pendingExerciseSessions[programExerciseId];
    if (pending != null) return pending;

    final workoutSessionId = state.workoutSessionId;
    if (workoutSessionId == null || !state.isActive) {
      return Future.value(Result.error(AppException('Cannot create exercise session without an active workout')));
    }

    final generation = _exerciseRegistryGeneration;
    late final Future<Result<ActiveWorkoutExerciseContext>> request;
    request =
        _createExerciseContext(
          programExercise: programExercise,
          workoutSessionId: workoutSessionId,
          generation: generation,
        ).whenComplete(() {
          if (identical(_pendingExerciseSessions[programExerciseId], request)) {
            final _ = _pendingExerciseSessions.remove(programExerciseId);
          }
        });
    _pendingExerciseSessions[programExerciseId] = request;
    return request;
  }

  Future<Result<ActiveWorkoutExerciseContext>> retryEnsureExerciseSession(
    ProgramExerciseEntity programExercise,
  ) {
    _exerciseSessionFailures.remove(programExercise.id);
    return ensureExerciseSession(programExercise);
  }

  /// Starts a fresh workout session and persists the session id to Drift so
  /// it can be restored if the app is killed mid-session.
  Future<void> startWorkout(ProgramDayEntity programDay) async {
    final workoutProgramDayId = programDay.id;

    _clearExerciseRegistry();

    emit(
      state.copyWith(
        programDay: programDay,
        workoutSessionId: null,
        currentExerciseIndex: 0,
        isStartingWorkout: true,
        summary: null,
        error: null,
      ),
    );

    final result = await _repository.startWorkoutSession(workoutProgramDayId);

    switch (result) {
      case Success(value: final sessionData):
        unawaited(_analytics.logEvent(AnalyticsEvents.workoutStart));
        logger.d('WorkoutSessionFlowCubit: started session ${sessionData.id}');

        unawaited(
          _sessionCache.saveActiveSession(
            remoteSessionId: sessionData.id,
            programDayId: workoutProgramDayId,
          ),
        );

        emit(
          state.copyWith(
            isStartingWorkout: false,
            workoutSessionId: sessionData.id,
            sessionStatus: WorkoutSessionStatus.active,
            isRestoredSession: false,
            restoredDurationSec: 0,
            restoredSets: const {},
          ),
        );

      case Failure(:final error):
        emit(
          state.copyWith(
            isStartingWorkout: false,
            error: 'Failed to start workout: $error',
          ),
        );
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

  Future<Result<ActiveWorkoutExerciseContext>> _createExerciseContext({
    required ProgramExerciseEntity programExercise,
    required int workoutSessionId,
    required int generation,
  }) async {
    final result = await _exerciseSessionRepository.createWorkoutExerciseSession(
      exerciseId: programExercise.exerciseDetails.id,
      workoutSessionId: workoutSessionId,
      workoutProgramExerciseId: programExercise.id,
      system: _measurementSystem,
    );

    switch (result) {
      case Success(value: final session):
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while creating exercise session'));
        }
        final context = _buildContext(programExercise, session);
        _exerciseContexts[programExercise.id] = context;
        return Result.success(context);

      case Failure(:final error):
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while creating exercise session'));
        }
        if (_isAmbiguousCreateFailure(error)) {
          final reconciled = await _reconcileExerciseContext(
            programExercise: programExercise,
            workoutSessionId: workoutSessionId,
            generation: generation,
          );
          if (reconciled != null) return Result.success(reconciled);
        }
        if (!_isCurrentRegistry(generation, workoutSessionId)) {
          return Result.error(AppException('Workout session changed while reconciling exercise session'));
        }
        _exerciseSessionFailures[programExercise.id] = error;
        return Result.error(error);
    }
  }

  Future<ActiveWorkoutExerciseContext?> _reconcileExerciseContext({
    required ProgramExerciseEntity programExercise,
    required int workoutSessionId,
    required int generation,
  }) async {
    final result = await _repository.getWorkoutSessionDetails(workoutSessionId);
    if (result case Success(value: final details?)) {
      final rawSessions = details.workoutSessions ?? const [];
      final selected = details.exerciseSessionsByProgramExerciseId;
      if (rawSessions.length > selected.length) {
        logger.w('WorkoutSessionFlowCubit: duplicate exercise sessions found during reconciliation');
      }
      final dto = selected[programExercise.id];
      if (dto == null || !_isCurrentRegistry(generation, workoutSessionId)) return null;

      final context = _buildContext(programExercise, dto.toEntity(_measurementSystem));
      _exerciseContexts[programExercise.id] = context;
      return context;
    }
    return null;
  }

  ActiveWorkoutExerciseContext _buildContext(
    ProgramExerciseEntity programExercise,
    WorkoutExerciseSessionEntity session,
  ) {
    return ActiveWorkoutExerciseContext(
      programExercise: programExercise,
      session: session,
      effectiveExercise: session.effectiveExercise ?? programExercise.exerciseDetails,
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
    _exerciseContexts.clear();
    _pendingExerciseSessions.clear();
    _exerciseSessionFailures.clear();
  }
}
