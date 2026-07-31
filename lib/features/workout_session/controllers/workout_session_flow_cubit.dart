import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
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
    this._analytics,
    this._sessionCache,
  ) : super(const WorkoutSessionFlowState());

  final WorkoutSessionRepository _repository;
  final AnalyticsService _analytics;
  final WorkoutSessionCacheRepository _sessionCache;

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
  }) {
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

  /// Starts a fresh workout session and persists the session id to Drift so
  /// it can be restored if the app is killed mid-session.
  Future<void> startWorkout(ProgramDayEntity programDay) async {
    final workoutProgramDayId = programDay.id;

    emit(
      state.copyWith(
        programDay: programDay,
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
  }
}
