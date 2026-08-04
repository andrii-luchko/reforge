import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';

class ActiveWorkoutExerciseContext {
  const ActiveWorkoutExerciseContext({
    required this.programExercise,
    required this.session,
    required this.effectiveExercise,
  });

  final ProgramExerciseEntity programExercise;
  final WorkoutExerciseSessionEntity session;
  final ExerciseDetailsEntity effectiveExercise;
}
