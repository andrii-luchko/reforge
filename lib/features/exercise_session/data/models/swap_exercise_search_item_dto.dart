import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_faction_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

part 'swap_exercise_search_item_dto.freezed.dart';
part 'swap_exercise_search_item_dto.g.dart';

@freezed
sealed class SwapExerciseSearchItemDTO with _$SwapExerciseSearchItemDTO {
  const SwapExerciseSearchItemDTO._();

  const factory SwapExerciseSearchItemDTO({
    required int id,
    required String name,
    required String description,
    required ExerciseFactionDTO faction,
    @Default(false) bool isPoseDetectionEnabled,
    String? poseDetectionPreset,
    String? videoInstructionUrl,
    String? thumbnailInstructionUrl,
    @Default([]) List<String> metrics,
    StaticDataDTO? staticData,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Map<String, Object?>> bodyParts,
  }) = _SwapExerciseSearchItemDTO;

  factory SwapExerciseSearchItemDTO.fromJson(Map<String, dynamic> json) => _$SwapExerciseSearchItemDTOFromJson(json);

  ExerciseDetailsEntity toEntity() {
    final tiers = staticData?.tiers ?? const [];
    return ExerciseDetailsEntity(
      id: id,
      name: name,
      description: description,
      key: null,
      metrics: metrics.map(WorkoutMetric.fromApiValue).whereType<WorkoutMetric>().toList(),
      isPoseDetectionEnabled: isPoseDetectionEnabled,
      poseDetectionPreset: switch (poseDetectionPreset) {
        'spine' => PoseDetectionPreset.spine,
        'legs' => PoseDetectionPreset.legs,
        _ => null,
      },
      runningTarget: staticData?.toRunningTarget(),
      isTiered: tiers.isNotEmpty,
      tiers: tiers,
      videoInstructionUrl: videoInstructionUrl,
      thumbnailInstructionUrl: thumbnailInstructionUrl,
      instructionsSteps: const {},
      faction: faction.toEntity(),
      factionId: faction.id,
    );
  }
}

@freezed
sealed class ExerciseFactionDTO with _$ExerciseFactionDTO {
  const ExerciseFactionDTO._();

  const factory ExerciseFactionDTO({
    required int id,
    required String name,
    required String slug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExerciseFactionDTO;

  factory ExerciseFactionDTO.fromJson(Map<String, dynamic> json) => _$ExerciseFactionDTOFromJson(json);

  ExerciseFactionEntity toEntity() => ExerciseFactionEntity(id: id, name: name, slug: slug);
}
