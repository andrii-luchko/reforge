import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';

class ActiveExerciseExecution {
  ActiveExerciseExecution({
    required this.spec,
    required this.workoutSessionId,
    required this.session,
    ExerciseDetailsEntity? effectiveExercise,
  }) : effectiveExercise = effectiveExercise ?? session.effectiveExercise ?? spec.details;

  final WorkoutExerciseSpec spec;
  final int workoutSessionId;
  final WorkoutExerciseSessionEntity session;

  int get exerciseSessionId => session.id;

  final ExerciseDetailsEntity effectiveExercise;
}
