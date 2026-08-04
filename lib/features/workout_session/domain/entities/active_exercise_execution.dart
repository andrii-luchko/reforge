import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';

class ActiveExerciseExecution {
  const ActiveExerciseExecution({
    required this.spec,
    required this.workoutSessionId,
    required this.exerciseSessionId,
  });

  final WorkoutExerciseSpec spec;
  final int workoutSessionId;
  final int exerciseSessionId;
}
