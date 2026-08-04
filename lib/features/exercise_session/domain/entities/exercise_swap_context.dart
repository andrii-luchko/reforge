import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

class ExerciseSwapRequestContext {
  const ExerciseSwapRequestContext({
    required this.workoutSessionId,
    required this.workoutExerciseSessionId,
    required this.currentExerciseId,
    required this.measurementSystem,
  });

  final int workoutSessionId;
  final int workoutExerciseSessionId;
  final int currentExerciseId;
  final MeasurementSystem measurementSystem;
}

class AppliedExerciseSwap {
  const AppliedExerciseSwap({
    required this.session,
    required this.exercise,
  });

  final WorkoutExerciseSessionEntity session;
  final ExerciseDetailsEntity exercise;

  bool get isConfirmed => session.swappedExerciseId == exercise.id;
}
