class UserStats {
  UserStats({
    required this.level,
    required this.xpToNextLevel,
    required this.totalXp,
    required this.totalWorkoutsDuration,
    required this.workoutsCount,
    required this.activeDays,
    required this.totalDays,
    required this.badgeName,
  });

  int level;
  int xpToNextLevel;
  int totalXp;

  int totalWorkoutsDuration;
  int workoutsCount;
  int activeDays;
  int totalDays;

  String? badgeName;

  int get currentXp => (totalXp - xpToNextLevel).clamp(0, totalXp);
}

extension UserStatsX on UserStats {
  ({int hours, int minutes}) get durationFormatted {
    final duration = Duration(seconds: totalWorkoutsDuration);
    return (
      hours: duration.inHours,
      minutes: duration.inMinutes.remainder(60),
    );
  }

  static UserStats mock({
    int level = 5,
    int xpToNextLevel = 450,
    int totalXp = 2000,
    int totalWorkoutsDuration = 3665,
    int workoutsCount = 12,
    int activeDays = 4,
    int totalDays = 7,
    String? badgeName = 'Iron Lifter',
  }) {
    return UserStats(
      level: level,
      xpToNextLevel: xpToNextLevel,
      totalXp: totalXp,
      totalWorkoutsDuration: totalWorkoutsDuration,
      workoutsCount: workoutsCount,
      activeDays: activeDays,
      totalDays: totalDays,
      badgeName: badgeName,
    );
  }
}
