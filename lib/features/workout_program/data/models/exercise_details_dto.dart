import 'package:freezed_annotation/freezed_annotation.dart';
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

    @Default([]) List<String> metrics,
    @Default(false) bool isPoseDetectionEnabled,
    String? poseDetectionPreset,
    @Default(false) bool isTiered,
    StaticDataDTO? staticData,

    String? videoInstructionUrl,
    String? thumbnailInstructionUrl,
    @Default({}) Map<String, String> instructionsSteps,
  }) = _ExerciseDetailsDTO;

  factory ExerciseDetailsDTO.fromJson(Map<String, dynamic> json) => _$ExerciseDetailsDTOFromJson(json);
}

@freezed
sealed class StaticDataDTO with _$StaticDataDTO {
  const factory StaticDataDTO({
    //TODO(Masayoshi):add static metric support
    @JsonKey(name: 'tier') @Default([]) List<Tier> tiers,
  }) = _StaticDataDTO;

  factory StaticDataDTO.fromJson(Map<String, dynamic> json) => _$StaticDataDTOFromJson(json);
}

extension ExerciseDetailsToEntityX on ExerciseDetailsDTO {
  ExerciseDetailsEntity toEntity() {
    return ExerciseDetailsEntity(
      id: id,
      name: name,
      description: description,
      key: key,
      type: ExerciseType.fromInt(type),
      metrics: metrics.map(_mapStringToMetric).whereType<WorkoutMetric>().toList(),
      poseDetectionPreset: _mapPoseDetectionPreset(poseDetectionPreset),
      isTiered: isTiered,
      tiers: staticData?.tiers ?? [],
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
    final metric = _mapStringToMetric(targetMetric);

    return ExerciseSegmentEntity(
      id: id,
      order: order,
      activity: SegmentActivity.fromJson(activity),
      targetMetric: metric,
      distanceM: distanceM ?? 0,
      durationSec: durationSec ?? 0,
    );
  }

  WorkoutMetric _mapStringToMetric(String value) {
    switch (value) {
      case 'weightKg':
        return WorkoutMetric.weight;
      case 'reps':
        return WorkoutMetric.reps;
      case 'durationSec':
      case 'duration':
        return WorkoutMetric.time;
      case 'distanceM':
        return WorkoutMetric.distance;
      case 'speedKmH':
        return WorkoutMetric.pace;
      case 'angleDeg':
        return WorkoutMetric.degrees;
      default:
        return WorkoutMetric.distance;
    }
  }
}
