import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_flow/data/models/program_exercise.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';

part 'program_day.freezed.dart';
part 'program_day.g.dart';

@Freezed(
  copyWith: false,
  fromJson: true,
  toStringOverride: true,
)
sealed class ProgramDay with _$ProgramDay {
  const ProgramDay._();

  const factory ProgramDay({
    required int id,
    required String name,
    required int dayNumber,

    required List<ProgramExercise> exercises,
  }) = _ProgramDay;

  factory ProgramDay.fromJson(Map<String, dynamic> json) => _$ProgramDayFromJson(json);

  List<ProgramExercise> get sortedExercises {
    final sortedList = [...exercises]..sort((a, b) => a.order.compareTo(b.order));
    return sortedList;
  }
}

extension ProgramDayToEntityX on ProgramDay {
  ProgramDayEntity toEntity() {
    return ProgramDayEntity(
      id: id,
      name: name,
      dayNumber: dayNumber,

      exercises: exercises.map((e) => e.toEntity()).toList(),
    );
  }
}
