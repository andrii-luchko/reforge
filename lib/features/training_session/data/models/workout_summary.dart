import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_summary.freezed.dart';
part 'workout_summary.g.dart';

@freezed
sealed class WorkoutSessionSummary with _$WorkoutSessionSummary {
  const factory WorkoutSessionSummary({
    @JsonKey(name: 'id') required int workoutSessionId,
    @JsonKey(name: 'duration') required int duration,
    @JsonKey(name: 'totalXpEarned') required int totalXpEarned,
    @JsonKey(name: 'earnedMilestones') List<UserWorkoutMilestone>? earnedMilestones,
    @JsonKey(name: 'levelUpParams') UserLevelUpParams? levelUpParams,
  }) = _WorkoutSessionSummary;

  factory WorkoutSessionSummary.fromJson(Map<String, dynamic> json) => _$WorkoutSessionSummaryFromJson(json);
}

@freezed
sealed class UserWorkoutMilestone with _$UserWorkoutMilestone {
  const factory UserWorkoutMilestone({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'tier') required int tier,
  }) = _UserWorkoutMilestone;

  factory UserWorkoutMilestone.fromJson(Map<String, dynamic> json) => _$UserWorkoutMilestoneFromJson(json);
}

@freezed
sealed class UserLevelUpParams with _$UserLevelUpParams {
  const factory UserLevelUpParams({
    @JsonKey(name: 'isLevelUp') required bool isLevelUp,
    @JsonKey(name: 'currentLevel') required int currentLevel,
  }) = _UserLevelUpParams;

  factory UserLevelUpParams.fromJson(Map<String, dynamic> json) => _$UserLevelUpParamsFromJson(json);
}
