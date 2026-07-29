enum ExerciseType {
  strength,
  endurance,
  flexibility;

  static ExerciseType? fromInt(int value) {
    switch (value) {
      case 1:
        return ExerciseType.strength;
      case 2:
        return ExerciseType.endurance;
      case 3:
        return ExerciseType.flexibility;
      default:
        return null;
    }
  }
}
