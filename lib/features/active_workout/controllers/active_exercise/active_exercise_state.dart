part of 'active_exercise_cubit.dart';

@freezed
sealed class ActiveExerciseState with _$ActiveExerciseState {
  const ActiveExerciseState._();
  const factory ActiveExerciseState({
    @Default('') String notes,
    @Default([]) List<WorkoutSet> sets,

    @Default(MeasurementSystem.metric) MeasurementSystem measureSystem,

    Tier? selectedTier,

    PreviousExerciseResult? previousResult,
    String? error,
    String? setValidationError,
    @Default(false) bool isLoading,
    @Default(false) bool isSendingSet,
    @Default(false) bool isSubmitted,
  }) = _ActiveExerciseState;

  bool get showNotesLimit => notes.length > 200;

  int get notesLimit => 500;
}
