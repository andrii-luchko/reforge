import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

class WorkoutExerciseSessionEntity {
  const WorkoutExerciseSessionEntity({
    required this.id,
    required this.exerciseId,
    required this.workoutSessionId,
    required this.workoutProgramExerciseId,
    required this.isSwapped,
    required this.swappedExerciseId,
    required this.isActive,
    required this.notes,
    required this.lastCompletedSet,
    required this.createdAt,
    required this.updatedAt,
    required this.sets,
    required this.exercise,
    required this.swappedExercise,
  });

  final int id;
  final int exerciseId;
  final int workoutSessionId;
  final int? workoutProgramExerciseId;
  final bool isSwapped;
  final int? swappedExerciseId;
  final bool isActive;
  final String? notes;
  final int? lastCompletedSet;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<WorkoutSet> sets;
  final ExerciseDetailsEntity? exercise;
  final ExerciseDetailsEntity? swappedExercise;

  ExerciseDetailsEntity? get effectiveExercise => isSwapped && swappedExercise != null ? swappedExercise : exercise;
}
