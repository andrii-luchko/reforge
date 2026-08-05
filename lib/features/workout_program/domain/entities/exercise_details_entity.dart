import 'package:flutter/foundation.dart';
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
    this.runningTarget,
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
  final ExerciseRunningTarget? runningTarget;

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
        runningTarget?.metric == WorkoutMetric.distance ||
        metrics.contains(WorkoutMetric.distance);
  }

  @override
  String toString() {
    return 'ExerciseDetailsEntity(\nid: $id,\n name: $name,\n description: $description,\n key: $key,\n metrics: $metrics, \nposeDetectionPreset: $poseDetectionPreset, \nrunningTarget: $runningTarget, \nisTiered: $isTiered,\n tiers: $tiers,\n videoInstructionUrl: $videoInstructionUrl, \nthumbnailInstructionUrl: $thumbnailInstructionUrl, \ninstructionsSteps: $instructionsSteps)';
  }
}

@immutable
class ExerciseRunningTarget {
  const ExerciseRunningTarget.distance(int meters) : metric = WorkoutMetric.distance, value = meters;

  const ExerciseRunningTarget.duration(int seconds) : metric = WorkoutMetric.time, value = seconds;

  final WorkoutMetric metric;
  final int value;

  @override
  bool operator ==(Object other) {
    return other is ExerciseRunningTarget && other.metric == metric && other.value == value;
  }

  @override
  int get hashCode => Object.hash(metric, value);

  @override
  String toString() => 'ExerciseRunningTarget(metric: $metric, value: $value)';
}

extension ExerciseDetailsEntityX on ExerciseDetailsEntity {
  List<String> availableTags(Translations t) {
    final tags = <String>[
      if (faction != null) faction!.name,
      ...metrics.map(
        (metric) => metric.title(
          t,
        ),
      ),
    ];
    return tags;
  }
}
