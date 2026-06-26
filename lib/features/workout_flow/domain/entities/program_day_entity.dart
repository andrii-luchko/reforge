import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

class ProgramDayEntity {
  const ProgramDayEntity({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.exercises,
  });

  final int id;
  final String name;
  final int dayNumber;
  final List<ProgramExerciseEntity> exercises;

  List<ProgramExerciseEntity> get sortedExercises {
    return [...exercises]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  String toString() {
    return 'ProgramDayEntity(\nid: $id,\n name: $name, \ndayNumber: $dayNumber, \nexercises: $exercises)';
  }
}
