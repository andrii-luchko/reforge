enum MainGoal {
  buildStrength,
  improveEndurance,
  enhanceFlexibility,
}

extension FitnessGoalExtension on MainGoal {
  String get title {
    switch (this) {
      case MainGoal.buildStrength:
        return 'Build Strength';
      case MainGoal.improveEndurance:
        return 'Improve Endurance';
      case MainGoal.enhanceFlexibility:
        return 'Enhance Flexibility';
    }
  }

  String get description {
    switch (this) {
      case MainGoal.buildStrength:
        return 'Focus on muscle growth and power';
      case MainGoal.improveEndurance:
        return 'Run farther and build stamina';
      case MainGoal.enhanceFlexibility:
        return 'Increase mobility and body control';
    }
  }
}
