part of 'workout_congratulations_cubit.dart';

@freezed
sealed class WorkoutCongratulationsState with _$WorkoutCongratulationsState {
  const factory WorkoutCongratulationsState({
    required WorkoutSessionSummaryEntity? workoutResult,

    @Default(null) WorkoutNavigationTarget? navigationTarget,
  }) = _WorkoutCongratulationsState;

  const WorkoutCongratulationsState._();
}

@freezed
sealed class WorkoutNavigationTarget with _$WorkoutNavigationTarget {
  const factory WorkoutNavigationTarget.achievement(int index) = _NavAchievement;

  const factory WorkoutNavigationTarget.summary() = _NavSummary;

  const factory WorkoutNavigationTarget.home() = _NavHome;
}
