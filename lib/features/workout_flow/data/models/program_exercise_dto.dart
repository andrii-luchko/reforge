// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_common/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

part 'program_exercise_dto.freezed.dart';
part 'program_exercise_dto.g.dart';

@freezed
sealed class ProgramExerciseDTO with _$ProgramExerciseDTO {
  const factory ProgramExerciseDTO({
    required int id,
    int? programDayId,
    required int sets,
    required int order,
    @JsonKey(name: 'exercise') required ExerciseDetailsDTO exerciseDetails,
  }) = _ProgramExerciseDTO;

  factory ProgramExerciseDTO.fromJson(Map<String, dynamic> json) => _$ProgramExerciseDTOFromJson(json);
}

extension ProgramExerciseToEntityX on ProgramExerciseDTO {
  ProgramExerciseEntity toEntity() {
    return ProgramExerciseEntity(
      id: id,
      programDayId: programDayId,
      sets: sets,
      order: order,

      exerciseDetails: exerciseDetails.toEntity(),
    );
  }
}
