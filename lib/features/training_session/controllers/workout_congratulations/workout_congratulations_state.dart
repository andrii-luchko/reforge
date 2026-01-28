part of 'workout_congratulations_cubit.dart';

@freezed
sealed class WorkoutCongratulationsState with _$WorkoutCongratulationsState {
  const factory WorkoutCongratulationsState({
    @Default([]) List<WorkoutCongratulationsContent> contentItems,
    @Default(0) int currentIndex,
    WorkoutSummaryContent? defaultSummary, // Always shown at the end if provided
  }) = _WorkoutCongratulationsState;
}

extension WorkoutCongratulationsStateX on WorkoutCongratulationsState {
  /// Get the current content item being displayed
  WorkoutCongratulationsContent? get currentContent {
    if (currentIndex >= 0 && currentIndex < contentItems.length) {
      return contentItems[currentIndex];
    }
    return null;
  }

  /// Check if there are more content items to show
  bool get hasNext => currentIndex < contentItems.length - 1;

  /// Check if we should show the default summary (at the end)
  bool get shouldShowSummary => currentIndex >= contentItems.length && defaultSummary != null;

  /// Check if we're done with all content
  bool get isComplete => currentIndex >= contentItems.length && defaultSummary == null;
}
