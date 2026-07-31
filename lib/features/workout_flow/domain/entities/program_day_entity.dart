import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

class ProgramDayEntity {
  const ProgramDayEntity({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.programExercises,
  });

  final int id;
  final String name;
  final int dayNumber;
  final List<ProgramExerciseEntity> programExercises;

  List<ProgramExerciseEntity> get sortedExercises {
    return [...programExercises]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  String toString() {
    return 'ProgramDayEntity(\nid: $id,\n name: $name, \ndayNumber: $dayNumber, \nexercises: $programExercises)';
  }
}
