import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';

class TrainingDetailsEntity {
  TrainingDetailsEntity({
    required this.id,
    required this.duration,
    required this.totalXpEarned,
    required this.exercises,
  });

  final int id;
  final int duration;
  final int totalXpEarned;

  final List<PreviousExerciseResult> exercises;
}
