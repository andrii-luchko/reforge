import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_flow/data/models/program_exercise_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';

part 'program_day_dto.freezed.dart';
part 'program_day_dto.g.dart';

@Freezed(
  copyWith: false,
  fromJson: true,
  toStringOverride: true,
)
sealed class ProgramDayDTO with _$ProgramDayDTO {
  const ProgramDayDTO._();

  const factory ProgramDayDTO({
    required int id,
    required String name,
    required int dayNumber,

    required List<ProgramExerciseDTO> exercises,
  }) = _ProgramDayDTO;

  factory ProgramDayDTO.fromJson(Map<String, dynamic> json) => _$ProgramDayDTOFromJson(json);

  List<ProgramExerciseDTO> get sortedExercises {
    final sortedList = [...exercises]..sort((a, b) => a.order.compareTo(b.order));
    return sortedList;
  }
}

extension ProgramDayToEntityX on ProgramDayDTO {
  ProgramDayEntity toEntity() {
    return ProgramDayEntity(
      id: id,
      name: name,
      dayNumber: dayNumber,

      exercises: exercises.map((e) => e.toEntity()).toList(),
    );
  }
}
