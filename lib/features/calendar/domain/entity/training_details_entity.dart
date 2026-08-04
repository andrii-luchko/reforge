import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class TrainingDetailsEntity {
  TrainingDetailsEntity({
    required this.id,
    required this.date,
    required this.duration,
    required this.totalXpEarned,
    required this.exercises,
    required this.measurementSystem,
  });
  final DateTime date;
  final int id;
  final int duration;
  final int totalXpEarned;
  final MeasurementSystem measurementSystem;

  final List<PreviousExerciseResult> exercises;
}

extension TrainingDetailsEntityX on TrainingDetailsEntity {
  bool get isEmptyDetails => totalXpEarned == 0 || exercises.isEmpty;
}
