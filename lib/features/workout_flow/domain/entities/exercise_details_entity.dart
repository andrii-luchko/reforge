import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_common/models/tier.dart';

class ExerciseDetailsEntity {
  const ExerciseDetailsEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.key,

    required this.metrics,

    required this.isTiered,
    required this.tiers,

    required this.videoInstructionUrl,
    required this.thumbnailInstructionUrl,
    required this.instructionsSteps,
  });

  final int id;
  final String name;
  final String description;
  final String key;

  final List<WorkoutMetric> metrics;

  final bool isTiered;
  final List<Tier> tiers;

  final String? videoInstructionUrl;
  final String? thumbnailInstructionUrl;
  final Map<String, String> instructionsSteps;

  /// True when this exercise requires running tracking (GPS or pedometer).
  ///
  /// An exercise is considered a running exercise if its metrics include
  /// [WorkoutMetric.distance] AND at least one of [WorkoutMetric.time] or
  /// [WorkoutMetric.pace]. This is the single source of truth for the entire
  /// codebase — use this getter rather than checking metrics manually.
  bool get isRunningExercise =>
      metrics.contains(WorkoutMetric.distance) &&
      (metrics.contains(WorkoutMetric.time) || metrics.contains(WorkoutMetric.pace));

  @override
  String toString() {
    return 'ExerciseDetailsEntity(\nid: $id,\n name: $name,\n description: $description,\n key: $key,\n metrics: $metrics, \nisTiered: $isTiered,\n tiers: $tiers,\n videoInstructionUrl: $videoInstructionUrl, \nthumbnailInstructionUrl: $thumbnailInstructionUrl, \ninstructionsSteps: $instructionsSteps)';
  }
}
