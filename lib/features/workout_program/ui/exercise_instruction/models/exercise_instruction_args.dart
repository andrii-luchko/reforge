import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

class ExerciseInstructionArgs {
  const ExerciseInstructionArgs({
    required this.exercise,
    this.coachNote,
  });

  final ExerciseDetailsEntity exercise;
  final String? coachNote;
}
