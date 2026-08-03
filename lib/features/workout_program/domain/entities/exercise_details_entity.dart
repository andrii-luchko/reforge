import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_faction_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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
    this.faction,
    this.factionId,
    this.isPoseDetectionEnabled = false,
  });

  final int id;
  final String name;
  final String description;

  /// Stable backend key. Search responses currently omit this field.
  final String? key;
  final ExerciseType? type;
  final ExerciseFactionEntity? faction;
  final int? factionId;
  final List<WorkoutMetric> metrics;
  final bool isPoseDetectionEnabled;
  final PoseDetectionPreset? poseDetectionPreset;

  final bool isTiered;
  final List<Tier> tiers;

  final String? videoInstructionUrl;
  final String? thumbnailInstructionUrl;
  final Map<String, String> instructionsSteps;

  /// Classifier used for exercises returned by swap-search.
  ///
  /// `durationSec` alone is intentionally not a running signal because it is
  /// also used by flexibility exercises.
  bool get isRunningSwapCandidate {
    final exerciseFaction = faction;
    return factionId == 3 ||
        exerciseFaction?.id == 3 ||
        exerciseFaction?.slug.toLowerCase() == 'gyohyo' ||
        metrics.contains(WorkoutMetric.distance);
  }

  @override
  String toString() {
    return 'ExerciseDetailsEntity(\nid: $id,\n name: $name,\n description: $description,\n key: $key,\n metrics: $metrics, \nposeDetectionPreset: $poseDetectionPreset, \nisTiered: $isTiered,\n tiers: $tiers,\n videoInstructionUrl: $videoInstructionUrl, \nthumbnailInstructionUrl: $thumbnailInstructionUrl, \ninstructionsSteps: $instructionsSteps)';
  }
}

extension ExerciseDetailsEntityX on ExerciseDetailsEntity {
  List<String> availableTags(Translations t) {
    final tags = <String>[
      if (faction != null) faction!.name,
      ...metrics.map((metric) => metric.title(t, null)),
    ];
    return tags;
  }
}
