// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/training_session/data/models/exercise_details.dart';

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
