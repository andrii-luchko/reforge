import 'package:reforge/features/workout_flow/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_segment_entity.dart';

class ProgramExerciseEntity {
  const ProgramExerciseEntity({
    required this.id,
    required this.programDayId,
    required this.sets,
    required this.order,
    required this.exerciseDetails,
    required this.executionMode,
    required this.segments,
  });

  final int id;
  final int? programDayId;
  final int sets;
  final int order;
  final ExecutionMode executionMode;
  final ExerciseDetailsEntity exerciseDetails;
  final List<ExerciseSegmentEntity> segments;

  @override
  String toString() {
    return 'ProgramExerciseEntity(\nid: $id, \nprogramDayId: $programDayId, \nsets: $sets, \norder: $order, \nexerciseDetails: $exerciseDetails)';
  }
}
