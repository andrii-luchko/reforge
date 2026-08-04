import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

part 'exercise_details_dto.freezed.dart';
part 'exercise_details_dto.g.dart';

@freezed
sealed class ExerciseDetailsDTO with _$ExerciseDetailsDTO {
  const ExerciseDetailsDTO._();

  const factory ExerciseDetailsDTO({
    required int id,
    required String name,
    required String description,
    required int type,
    required String key,
    int? factionId,

    @Default([]) List<String> metrics,
    @Default(false) bool isPoseDetectionEnabled,
    String? poseDetectionPreset,
    @Default(false) bool isTiered,
    StaticDataDTO? staticData,

    String? videoInstructionUrl,
    String? thumbnailInstructionUrl,
    @JsonKey(
      name: 'instructions',
      fromJson: _instructionsFromJson,
      toJson: _instructionsToJson,
    )
    @Default({})
    Map<String, String> instructionsSteps,
  }) = _ExerciseDetailsDTO;

  factory ExerciseDetailsDTO.fromJson(Map<String, dynamic> json) => _$ExerciseDetailsDTOFromJson(json);
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

@freezed
sealed class StaticDataDTO with _$StaticDataDTO {
  const factory StaticDataDTO({
    @JsonKey(name: 'tier') @Default([]) List<Tier> tiers,
    int? distanceM,
    int? durationSec,
  }) = _StaticDataDTO;

  factory StaticDataDTO.fromJson(Map<String, dynamic> json) => _$StaticDataDTOFromJson(json);
}

extension StaticDataToRunningTargetX on StaticDataDTO {
  ExerciseRunningTarget? toRunningTarget() {
    final hasDistance = distanceM != null;
    final hasDuration = durationSec != null;

    if (!hasDistance && !hasDuration) return null;

    if ((distanceM ?? 1) <= 0 || (durationSec ?? 1) <= 0 || (hasDistance && hasDuration)) {
      logger.w(
        'Invalid static running target: distanceM=$distanceM, durationSec=$durationSec. Falling back to free run.',
      );
      return null;
    }

    if (distanceM case final meters?) {
      return ExerciseRunningTarget.distance(meters);
    }

    return ExerciseRunningTarget.duration(durationSec!);
  }
}

extension ExerciseDetailsToEntityX on ExerciseDetailsDTO {
  ExerciseDetailsEntity toEntity() {
    return ExerciseDetailsEntity(
      id: id,
      name: name,
      description: description,
      key: key,
      type: ExerciseType.fromInt(type),
      factionId: factionId,
      metrics: metrics.map(WorkoutMetric.fromApiValue).whereType<WorkoutMetric>().toList(),
      isPoseDetectionEnabled: isPoseDetectionEnabled,
      poseDetectionPreset: _mapPoseDetectionPreset(poseDetectionPreset),
      runningTarget: staticData?.toRunningTarget(),
      isTiered: isTiered,
      tiers: staticData?.tiers ?? [],
      videoInstructionUrl: videoInstructionUrl,
      thumbnailInstructionUrl: thumbnailInstructionUrl,
      instructionsSteps: instructionsSteps,
    );
  }

  PoseDetectionPreset? _mapPoseDetectionPreset(String? value) {
    return switch (value) {
      'spine' => PoseDetectionPreset.spine,
      'legs' => PoseDetectionPreset.legs,
      _ => null,
    };
  }
}

@freezed
sealed class ExerciseSegmentDTO with _$ExerciseSegmentDTO {
  const factory ExerciseSegmentDTO({
    required int id,
    required int order,
    required String activity,
    required String targetMetric,
    String? label,
    int? distanceM,
    int? durationSec,
  }) = _ExerciseSegmentDTO;

  factory ExerciseSegmentDTO.fromJson(Map<String, dynamic> json) => _$ExerciseSegmentDTOFromJson(json);
}

extension ExerciseSegmentToEntityX on ExerciseSegmentDTO {
  ExerciseSegmentEntity toEntity() {
    final metric = WorkoutMetric.fromApiValue(targetMetric) ?? WorkoutMetric.distance;

    return ExerciseSegmentEntity(
      id: id,
      order: order,
      activity: SegmentActivity.fromJson(activity),
      targetMetric: metric,
      distanceM: distanceM ?? 0,
      durationSec: durationSec ?? 0,
    );
  }
}
