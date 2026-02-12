import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

import 'package:reforge/features/workout_common/models/tier.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';

part 'exercise_details_dto.freezed.dart';
part 'exercise_details_dto.g.dart';

@freezed
sealed class ExerciseDetailsDTO with _$ExerciseDetailsDTO {
  const ExerciseDetailsDTO._();

  const factory ExerciseDetailsDTO({
    required int id,
    required String name,
    required String description,
    required String key,

    @Default([]) List<String> metrics,

    @Default(false) bool isTiered,
    @Default([]) List<Tier> tiers,

    String? videoInstructionUrl,
    String? thumbnailInstructionUrl,
    @Default({}) Map<String, String> instructionsSteps,
  }) = _ExerciseDetailsDTO;

  factory ExerciseDetailsDTO.fromJson(Map<String, dynamic> json) => _$ExerciseDetailsDTOFromJson(json);
}

extension ExerciseDetailsToEntityX on ExerciseDetailsDTO {
  ExerciseDetailsEntity toEntity() {
    return ExerciseDetailsEntity(
      id: id,
      name: name,
      description: description,
      key: key,

      metrics: metrics.map(_mapStringToMetric).whereType<WorkoutMetric>().toList(),
      isTiered: isTiered,
      tiers: tiers,
      videoInstructionUrl: videoInstructionUrl,
      thumbnailInstructionUrl: thumbnailInstructionUrl,
      instructionsSteps: instructionsSteps,
    );
  }

  WorkoutMetric? _mapStringToMetric(String value) {
    switch (value) {
      case 'weightKg':
        return WorkoutMetric.weight;
      case 'reps':
        return WorkoutMetric.reps;
      case 'durationSec':
        return WorkoutMetric.time;
      case 'distanceM':
        return WorkoutMetric.distance;
      case 'speedKmH':
        return WorkoutMetric.pace;
      case 'angleDeg':
        return WorkoutMetric.degrees;
      default:
        return null;
    }
  }
}
