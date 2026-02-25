import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';

class ProgramExerciseEntity {
  const ProgramExerciseEntity({
    required this.id,
    required this.programDayId,
    required this.sets,
    required this.order,
    required this.exerciseDetails,
  });

  final int id;
  final int? programDayId;
  final int sets;
  final int order;
  final ExerciseDetailsEntity exerciseDetails;

  @override
  String toString() {
    return 'ProgramExerciseEntity(id: $id, programDayId: $programDayId, sets: $sets, order: $order, exerciseDetails: $exerciseDetails)';
  }
}
