import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

class AppliedExerciseSwap {
  const AppliedExerciseSwap({
    required this.session,
    required this.effectiveExercise,
  });

  final WorkoutExerciseSessionEntity session;
  final ExerciseDetailsEntity effectiveExercise;
}
