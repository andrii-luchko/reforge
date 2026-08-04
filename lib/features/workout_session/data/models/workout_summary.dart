import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';

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
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'tier') required int tier,
    @JsonKey(name: 'iconUrl') String? iconUrl,
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

extension WorkoutSessionMapper on WorkoutSessionSummary {
  WorkoutSessionSummaryEntity toEntity() {
    return WorkoutSessionSummaryEntity(
      id: workoutSessionId,
      duration: duration,
      totalXpEarned: totalXpEarned,
      earnedMilestones: _filterHighestTierMilestones(earnedMilestones),

      isLevelUp: levelUpParams?.isLevelUp ?? false,
      currentLevel: levelUpParams?.currentLevel,
    );
  }

  List<UserWorkoutMilestoneEntity> _filterHighestTierMilestones(List<UserWorkoutMilestone>? list) {
    if (list == null || list.isEmpty) return [];

    final bestMilestones = <int, UserWorkoutMilestoneEntity>{};

    for (final item in list) {
      final existing = bestMilestones[item.id];

      if (existing == null || item.tier > existing.tier) {
        bestMilestones[item.id] = item.toEntity();
      }
    }

    return bestMilestones.values.toList();
  }
}

extension UserWorkoutMilestoneMapper on UserWorkoutMilestone {
  UserWorkoutMilestoneEntity toEntity() {
    return UserWorkoutMilestoneEntity(
      id: id,
      name: name,
      tier: tier,
      iconUrl: iconUrl,
    );
  }
}
