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

  @override
  String toString() {
    return 'ExerciseDetailsEntity(id: $id, name: $name, description: $description, key: $key, metrics: $metrics, isTiered: $isTiered, tiers: $tiers, videoInstructionUrl: $videoInstructionUrl, thumbnailInstructionUrl: $thumbnailInstructionUrl, instructionsSteps: $instructionsSteps)';
  }
}
