part of 'workout_session_flow_cubit.dart';

@freezed
sealed class WorkoutSessionFlowState with _$WorkoutSessionFlowState {
  const WorkoutSessionFlowState._();

  const factory WorkoutSessionFlowState({
    WorkoutExecutionPlan? executionPlan,

    WorkoutStartIntent? startIntent,

    /// Retained as program-definition metadata while program UI is migrated.
    ProgramDayEntity? programDay,

    @Default(false) bool isLoading,

    @Default(false) bool isStartingWorkout,

    int? workoutSessionId,

    @Default(0) int currentExerciseIndex,

    WorkoutSessionStatus? sessionStatus,

    WorkoutSessionSummaryEntity? summary,

    String? error,

    // ── Restore context ──────────────────────────────────────────────────────
    // These fields are populated by [WorkoutSessionFlowCubit.initFromRestore] and
    // consumed by ActiveExerciseCubit / ActiveWorkoutShell.

    /// True when this session was seeded by a restore (not a fresh start).
    @Default(false) bool isRestoredSession,

    /// Accumulated duration in seconds at the time of interruption.
    /// Used to initialise the timer from the correct offset.
    @Default(0) int restoredDurationSec,

    /// Previously completed sets, keyed by workoutProgramExerciseId.
    @Default({}) Map<int, List<WorkoutSet>> restoredSets,

    // ── Running restore context ──────────────────────────────────────────────

    /// Completed running laps from Drift, keyed by programExerciseId.
    @Default({}) Map<int, List<ActiveRunningSet>> restoredRunningLaps,

    /// The in-progress (unfinished) running lap from Drift.
    /// Non-null only when the app was killed mid-lap during a running exercise.
    ActiveRunningSet? restoredInProgressLap,
  }) = _WorkoutSessionFlowState;

  bool get isEmptyData => executionPlan == null;

  bool get isPrepared => executionPlan != null && workoutSessionId == null;

  bool get isFinished =>
      sessionStatus == WorkoutSessionStatus.completed || sessionStatus == WorkoutSessionStatus.canceled;

  bool get isActive => sessionStatus == WorkoutSessionStatus.active;

  bool get isCanceled => sessionStatus == WorkoutSessionStatus.canceled;

  bool get isCompleted => sessionStatus == WorkoutSessionStatus.completed;

  WorkoutExerciseSpec? get currentExercise {
    final exercises = executionPlan?.exercises;
    if (exercises == null || exercises.isEmpty) return null;
    if (currentExerciseIndex >= exercises.length) return null;
    return exercises[currentExerciseIndex];
  }

  ProgramExerciseEntity? get currentProgramExercise {
    final programExerciseId = currentExercise?.workoutProgramExerciseId;
    if (programExerciseId == null) return null;
    for (final exercise in programDay?.programExercises ?? const <ProgramExerciseEntity>[]) {
      if (exercise.id == programExerciseId) return exercise;
    }
    return null;
  }

  int get totalExercises => executionPlan?.exercises.length ?? 0;

  bool get isLastExercise => currentExerciseIndex == (totalExercises - 1);

  bool get isFirstExercise => currentExerciseIndex == 0;
}
