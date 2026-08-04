import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';

class WorkoutProgramExerciseBinding {
  const WorkoutProgramExerciseBinding({
    required this.programDayId,
    required this.programExerciseId,
    required this.order,
    required this.executionMode,
  });

  final int programDayId;
  final int programExerciseId;
  final int order;
  final ExecutionMode executionMode;
}
