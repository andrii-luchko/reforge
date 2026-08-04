sealed class WorkoutSource {
  const WorkoutSource();

  const factory WorkoutSource.program({required int programDayId}) = ProgramWorkoutSource;

  const factory WorkoutSource.adHoc() = AdHocWorkoutSource;

  bool get isProgram => this is ProgramWorkoutSource;
}

final class ProgramWorkoutSource extends WorkoutSource {
  const ProgramWorkoutSource({required this.programDayId});

  final int programDayId;
}

final class AdHocWorkoutSource extends WorkoutSource {
  const AdHocWorkoutSource();
}
