part of 'exercise_swap_cubit.dart';

@freezed
sealed class ExerciseSwapState with _$ExerciseSwapState {
  const ExerciseSwapState._();

  const factory ExerciseSwapState({
    @Default([]) List<ExerciseDetailsEntity> exercises,
    @Default('') String query,
    int? factionId,
    @Default(1) int page,
    @Default(1) int pages,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    int? selectedExerciseId,
    int? swappingExerciseId,
    String? error,
  }) = _ExerciseSwapState;

  bool get hasMore => page < pages;

  bool get isSwapping => swappingExerciseId != null;

  ExerciseDetailsEntity? get selectedExercise =>
      exercises.firstWhereOrNull((exercise) => exercise.id == selectedExerciseId);
}
