import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';

class TrainingDetailsEntity {
  TrainingDetailsEntity({
    required this.id,
    required this.duration,
    required this.totalXpEarned,
    required this.exercises,
    required this.measurementSystem,
  });

  final int id;
  final int duration;
  final int totalXpEarned;
  final MeasurementSystem measurementSystem;

  final List<PreviousExerciseResult> exercises;
}
