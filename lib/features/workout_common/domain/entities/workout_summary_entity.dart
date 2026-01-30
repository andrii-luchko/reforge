class WorkoutSessionSummaryEntity {
  const WorkoutSessionSummaryEntity({
    required this.id,
    required this.duration,
    required this.totalXpEarned,
    required this.earnedMilestones,
    required this.isLevelUp,
    required this.currentLevel,
  });

  final int id;
  final int duration;
  final int totalXpEarned;
  final List<UserWorkoutMilestoneEntity> earnedMilestones;

  final bool isLevelUp;
  final int? currentLevel;
}

class UserWorkoutMilestoneEntity {
  const UserWorkoutMilestoneEntity({
    required this.id,
    required this.name,
    required this.tier,
    required this.iconUrl,
  });

  final int id;
  final String name;
  final int tier;
  final String? iconUrl;
}
