import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class RunningExerciseConfig {
  const RunningExerciseConfig({
    required this.workoutSessionId,
    required this.workoutProgramExerciseId,
    required this.exercise,
    required this.segments,
    required this.staticTargetSetCount,
  }) : assert(staticTargetSetCount > 0, 'staticTargetSetCount must be positive');

  final int workoutSessionId;
  final int workoutProgramExerciseId;
  final ExerciseDetailsEntity exercise;
  final List<ExerciseSegmentEntity> segments;
  final int staticTargetSetCount;

  List<LapLimit> get limits {
    if (segments.isNotEmpty) {
      return segments
          .map(
            (segment) => LapLimit(
              metric: segment.targetMetric,
              limitValue: segment.targetMetric == WorkoutMetric.time
                  ? segment.durationSec.toDouble()
                  : segment.distanceM.toDouble(),
              segmentId: segment.id,
              activityType: segment.activity,
            ),
          )
          .toList();
    }

    final target = exercise.runningTarget;
    if (target == null) return const [];

    return List.generate(
      staticTargetSetCount,
      (_) => LapLimit(
        metric: target.metric,
        limitValue: target.value.toDouble(),
      ),
      growable: false,
    );
  }

  bool get isFreeRun => limits.isEmpty;
}
