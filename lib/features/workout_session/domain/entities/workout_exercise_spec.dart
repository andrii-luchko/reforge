import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_program_exercise_binding.dart';

class WorkoutExerciseSpec {
  const WorkoutExerciseSpec({
    required this.executionKey,
    required this.details,
    required this.targetSetCount,
    required this.segments,
    required this.programBinding,
  });

  final String executionKey;
  final ExerciseDetailsEntity details;
  final int? targetSetCount;
  final List<ExerciseSegmentEntity> segments;
  final WorkoutProgramExerciseBinding? programBinding;

  int get exerciseId => details.id;

  int? get workoutProgramExerciseId => programBinding?.programExerciseId;

  bool get isRunningExercise {
    if (segments.isNotEmpty) return true;

    final metrics = details.metrics;
    final hasTime = metrics.contains(WorkoutMetric.time);
    final hasDistance = metrics.contains(WorkoutMetric.distance);
    final hasRunningRate = metrics.contains(WorkoutMetric.speed) || metrics.contains(WorkoutMetric.pace);
    final runningTarget = details.runningTarget;

    if (runningTarget != null && (runningTarget.metric == WorkoutMetric.distance || hasDistance)) {
      return true;
    }
    if (hasDistance && (hasTime || hasRunningRate)) return true;
    if (hasTime && details.type == ExerciseType.endurance) return true;

    return details.key?.toLowerCase().contains('run') ?? false;
  }
}
