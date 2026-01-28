import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/training_session/data/models/tier.dart';
import 'package:reforge/features/training_session/domain/enums/workout_metrics.dart';

part 'exercise_details.freezed.dart';
part 'exercise_details.g.dart';

@freezed
sealed class ExerciseDetails with _$ExerciseDetails {
  const ExerciseDetails._();

  const factory ExerciseDetails({
    required int id,
    required String name,
    required String description,
    required String key,

    @Default([]) List<WorkoutMetric> metrics,

    @Default(false) bool isTiered,
    @Default([]) List<Tier> tiers,

    String? videoInstructionUrl,
    String? thumbnailInstructionUrl,
    @Default({}) Map<String, String> instructionsSteps,
  }) = _ExerciseDetails;

  factory ExerciseDetails.fromJson(Map<String, dynamic> json) => _$ExerciseDetailsFromJson(json);
}
