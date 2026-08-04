import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_faction_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

part 'exercise_catalog_item_dto.freezed.dart';
part 'exercise_catalog_item_dto.g.dart';

@freezed
sealed class ExerciseCatalogItemDTO with _$ExerciseCatalogItemDTO {
  const ExerciseCatalogItemDTO._();

  const factory ExerciseCatalogItemDTO({
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
    @JsonKey(
      name: 'instructions',
      fromJson: _instructionsFromJson,
      toJson: _instructionsToJson,
    )
    @Default({})
    Map<String, String> instructionsSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Map<String, Object?>> bodyParts,
  }) = _ExerciseCatalogItemDTO;

  factory ExerciseCatalogItemDTO.fromJson(Map<String, dynamic> json) => _$ExerciseCatalogItemDTOFromJson(json);

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
      instructionsSteps: instructionsSteps,
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

Map<String, String> _instructionsFromJson(Object? json) {
  if (json is! List) return const {};

  return {
    for (final instruction in json)
      if (instruction is Map)
        for (final entry in instruction.entries)
          if (entry.key is String && entry.value is String) entry.key as String: entry.value as String,
  };
}

List<Map<String, String>> _instructionsToJson(Map<String, String> instructions) {
  return [
    for (final entry in instructions.entries) {entry.key: entry.value},
  ];
}
