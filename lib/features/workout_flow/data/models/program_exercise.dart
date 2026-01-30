// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_common/models/exercise_details.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

part 'program_exercise.freezed.dart';
part 'program_exercise.g.dart';

@freezed
sealed class ProgramExercise with _$ProgramExercise {
  const factory ProgramExercise({
    required int id,
    int? programDayId,
    required int sets,
    required int order,
    @JsonKey(name: 'exercise') required ExerciseDetails exerciseDetails,
  }) = _ProgramExercise;

  factory ProgramExercise.fromJson(Map<String, dynamic> json) => _$ProgramExerciseFromJson(json);
}

extension ProgramExerciseToEntityX on ProgramExercise {
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
