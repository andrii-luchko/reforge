part of 'workout_flow_cubit.dart';

@freezed
sealed class WorkoutFlowState with _$WorkoutFlowState {
  const WorkoutFlowState._();

  const factory WorkoutFlowState({
    ProgramDayEntity? programDay,

    @Default(false) bool isLoading,

    @Default(false) bool isStartingWorkout,

    int? workoutSessionId,

    @Default(0) int currentExerciseIndex,

    WorkoutSessionStatus? sessionStatus,

    WorkoutSessionSummaryEntity? summary,

    String? error,
  }) = _WorkoutFlowState;

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
}
