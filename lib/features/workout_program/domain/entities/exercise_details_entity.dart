import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class ExerciseDetailsEntity {
  const ExerciseDetailsEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.key,

    required this.metrics,
    required this.poseDetectionPreset,

    required this.isTiered,
    required this.tiers,

    required this.videoInstructionUrl,
    required this.thumbnailInstructionUrl,
    required this.instructionsSteps,
    this.type,
  });

  final int id;
  final String name;
  final String description;
  final String key;
  final ExerciseType? type;
  final List<WorkoutMetric> metrics;
  final PoseDetectionPreset? poseDetectionPreset;

  final bool isTiered;
  final List<Tier> tiers;

  final String? videoInstructionUrl;
  final String? thumbnailInstructionUrl;
  final Map<String, String> instructionsSteps;

  @override
  String toString() {
    return 'ExerciseDetailsEntity(\nid: $id,\n name: $name,\n description: $description,\n key: $key,\n metrics: $metrics, \nposeDetectionPreset: $poseDetectionPreset, \nisTiered: $isTiered,\n tiers: $tiers,\n videoInstructionUrl: $videoInstructionUrl, \nthumbnailInstructionUrl: $thumbnailInstructionUrl, \ninstructionsSteps: $instructionsSteps)';
  }
}
