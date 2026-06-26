part of 'workout_flow_cubit.dart';

@freezed
sealed class WorkoutFlowState with _$WorkoutFlowState {
  const WorkoutFlowState._();

  const factory WorkoutFlowState({
    ProgramDayEntity? programDay,

    @Default(true) bool isLoading,

    @Default(false) bool isStartingWorkout,

    int? workoutSessionId,

    @Default(0) int currentExerciseIndex,

    WorkoutSessionStatus? sessionStatus,

    WorkoutSessionSummaryEntity? summary,

    String? error,

    // ── Restore context ──────────────────────────────────────────────────────
    // These fields are populated by [WorkoutFlowCubit.initFromRestore] and
    // consumed by ActiveExerciseCubit / ActiveWorkoutShell.

    /// True when this session was seeded by a restore (not a fresh start).
    @Default(false) bool isRestoredSession,

    /// Accumulated duration in seconds at the time of interruption.
    /// Used to initialise the timer from the correct offset.
    @Default(0) int restoredDurationSec,

    /// Previously completed sets, keyed by workoutProgramExerciseId.
    @Default({}) Map<int, List<WorkoutSet>> restoredSets,
  }) = _WorkoutFlowState;

  bool get isEmptyData => programDay == null;

  bool get isFinished =>
      sessionStatus == WorkoutSessionStatus.completed || sessionStatus == WorkoutSessionStatus.canceled;

  bool get isActive => sessionStatus == WorkoutSessionStatus.active;

  bool get isCanceled => sessionStatus == WorkoutSessionStatus.canceled;

  bool get isCompleted => sessionStatus == WorkoutSessionStatus.completed;

  ProgramExerciseEntity? get currentExercise {
    if (programDay == null || programDay!.sortedExercises.isEmpty) return null;
    if (currentExerciseIndex >= programDay!.sortedExercises.length) return null;
    return programDay!.sortedExercises[currentExerciseIndex];
  }

  int get totalExercises => programDay?.sortedExercises.length ?? 0;

  bool get isLastExercise => currentExerciseIndex == (totalExercises - 1);

  bool get isFirstExercise => currentExerciseIndex == 0;
}
