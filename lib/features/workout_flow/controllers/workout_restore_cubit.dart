import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/models/exercise_session_dto.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_flow/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_flow/domain/repositories/training_session_repository.dart';

part 'workout_restore_state.dart';
part 'workout_restore_cubit.freezed.dart';

/// Singleton cubit responsible solely for detecting and restoring interrupted
/// workout sessions. Completely decoupled from WorkoutFlowCubit's
/// active-workout execution flow.
///
/// Lifecycle:
/// 1. Call checkForInterrupted() from any screen that wants to surface a restore prompt.
/// 2. Listen to WorkoutRestoreState.pendingRestore and show a dialog.
/// 3. On "Continue" → call restoreSession(); navigate based on WorkoutRestoreState.restored.
/// 4. On "Start Fresh" / dismiss → call abandonSession().
@lazySingleton
class WorkoutRestoreCubit extends Cubit<WorkoutRestoreState> {
  WorkoutRestoreCubit(
    this._sessionCache,
    this._repository,
    this._flowCubit,
  ) : super(const WorkoutRestoreState.idle());

  final WorkoutSessionCacheRepository _sessionCache;
  final TrainingSessionRepository _repository;

  /// Injected so restore can populate the active-workout cubit directly.
  final WorkoutFlowCubit _flowCubit;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Checks local Drift cache for an interrupted session and verifies it
  /// is still active on the backend.
  ///
  /// Emits WorkoutRestoreState.pendingRestore if a restorable session
  /// exists, WorkoutRestoreState.none otherwise. Safe to call multiple
  /// times — won't re-check if already checking or restoring.
  Future<void> checkForInterrupted() async {
    final current = state;
    if (current is WorkoutRestoreChecking || current is WorkoutRestoreRestoring) return;

    emit(const WorkoutRestoreState.checking());

    final cached = await _sessionCache.getActiveSession();
    if (cached == null) {
      emit(const WorkoutRestoreState.none());
      return;
    }

    final result = await _repository.getWorkoutSessionDetails(cached.remoteSessionId);

    switch (result) {
      case Failure():
        // Cannot verify — fail silently, don't block the user.
        logger.w('WorkoutRestoreCubit: could not verify cached session ${cached.remoteSessionId}');
        emit(const WorkoutRestoreState.none());
        return;
      case Success(value: final details):
        if (details == null) {
          // Session is not exist — clean stale cache entry.
          await _sessionCache.clearActiveSession();
          emit(const WorkoutRestoreState.none());
          return;
        }

        if (details.status != WorkoutSessionStatus.active) {
          // Session is already closed on the backend — clean stale cache entry.
          await _sessionCache.clearActiveSession();
          emit(const WorkoutRestoreState.none());
          return;
        }
        emit(
          WorkoutRestoreState.pendingRestore(
            sessionId: cached.remoteSessionId,
            programDayId: cached.programDayId,
            cachedDurationSec: cached.durationSec,
            session: details,
          ),
        );
    }
  }

  /// Fetches full session details + program day in parallel, populates
  /// WorkoutFlowCubit via initFromRestore(), and emits
  /// WorkoutRestoreState.restored with the exercise id to navigate to.
  Future<void> restoreSession() async {
    final pending = state;
    if (pending is! WorkoutRestorePending) return;

    emit(const WorkoutRestoreState.restoring());

    // Kick off both requests in parallel.

    final dayFuture = _repository.getWorkoutByDay(pending.programDayId);

    final dayResult = await dayFuture;

    if (dayResult is Failure) {
      emit(const WorkoutRestoreState.error('Failed to restore workout session'));
      return;
    }

    final details = pending.session;
    final programDay = (dayResult as Success<ProgramDayEntity?>).value;

    if (programDay == null) {
      emit(const WorkoutRestoreState.error('Workout program day not found'));
      return;
    }

    final restoredSets = _buildRestoredSetsMap(details);
    final resumeIndex = _findLastExerciseWithSets(programDay, restoredSets);
    final resumeExercise = programDay.sortedExercises[resumeIndex];

    logger.d(
      'WorkoutRestoreCubit: restoring session ${pending.sessionId} '
      '— resuming at exercise index $resumeIndex '
      '(id: ${resumeExercise.exerciseDetails.id})',
    );

    // Populate the active-workout cubit so it's ready when we navigate.
    _flowCubit.initFromRestore(
      sessionId: pending.sessionId,
      programDay: programDay,
      durationSec: pending.cachedDurationSec,
      restoredSets: restoredSets,
      startIndex: resumeIndex,
    );

    emit(WorkoutRestoreState.restored(resumeExerciseId: resumeExercise.exerciseDetails.id));
  }

  /// Cancels the interrupted session on the backend (best-effort) and clears
  /// the local cache entry. Emits [WorkoutRestoreState.none] when done.
  Future<void> abandonSession() async {
    final pending = state;

    var sessionId = pending is WorkoutRestorePending ? pending.sessionId : null;
    var cachedDuration = pending is WorkoutRestorePending ? pending.cachedDurationSec : 0;

    if (pending is! WorkoutRestorePending) {
      // Fallback: read directly from Drift in case state was reset.
      final cached = await _sessionCache.getActiveSession();
      sessionId = cached?.remoteSessionId;
      cachedDuration = cached?.durationSec ?? 0;
    }

    if (sessionId != null) {
      // Best-effort — ignore failure.
      await _repository.endWorkoutSession(
        status: WorkoutSessionStatus.canceled,
        workoutSessionId: sessionId,
        workoutSessionDuration: cachedDuration,
      );
    }

    await _sessionCache.clearActiveSession();
    emit(const WorkoutRestoreState.none());
  }

  /// Resets back to idle — use when leaving a screen that was listening.
  void reset() => emit(const WorkoutRestoreState.idle());

  // ── Private helpers ────────────────────────────────────────────────────────

  Map<int, List<WorkoutSet>> _buildRestoredSetsMap(WorkoutSessionDetailsDTO details) {
    final system = _repository.getUserMeasurementSystem() ?? MeasurementSystem.metric;
    final map = <int, List<WorkoutSet>>{};
    final sessions = details.workoutSessions ?? <ExerciseSessionDTO>[];
    for (final session in sessions) {
      final sets = (session.sets ?? <ExerciseSetDTO>[]).map((s) => s.toWorkoutSet(system)).toList();
      if (sets.isNotEmpty) {
        map[session.workoutProgramExerciseId] = sets;
      }
    }
    return map;
  }

  /// Returns the index of the LAST exercise that has recorded sets.
  /// This is where we resume — not the first empty exercise.
  ///
  /// Example:
  ///   Exercise 1 → 2 sets
  ///   Exercise 2 → 1 set  ← returns index 1
  ///   Exercise 3 → 0 sets
  int _findLastExerciseWithSets(
    ProgramDayEntity day,
    Map<int, List<WorkoutSet>> restoredSets,
  ) {
    final sorted = day.sortedExercises;
    for (var i = sorted.length - 1; i >= 0; i--) {
      if ((restoredSets[sorted[i].id] ?? []).isNotEmpty) return i;
    }
    // No sets recorded at all — start from the beginning.
    return 0;
  }
}
