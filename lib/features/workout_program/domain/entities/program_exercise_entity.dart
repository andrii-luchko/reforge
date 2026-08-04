import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class ProgramExerciseEntity {
  const ProgramExerciseEntity({
    required this.id,
    required this.programDayId,
    required this.sets,
    required this.order,
    required this.exerciseDetails,
    required this.executionMode,
    required this.segments,
  });

  final int id;
  final int? programDayId;
  final int sets;
  final int order;
  final ExecutionMode executionMode;
  final ExerciseDetailsEntity exerciseDetails;
  final List<ExerciseSegmentEntity> segments;

  /// Whether this exercise should use the running workout flow.
  ///
  /// Segments and the exercise key are explicit running signals. For exercises
  /// without either of them, the backend metrics are used first. A time-only
  /// exercise is treated as running only when it is also an endurance exercise.
  bool get isRunningExercise {
    if (segments.isNotEmpty) return true;

    final metrics = exerciseDetails.metrics;
    final hasTime = metrics.contains(WorkoutMetric.time);
    final hasDistance = metrics.contains(WorkoutMetric.distance);
    final hasPace = metrics.contains(WorkoutMetric.pace);
    final runningTarget = exerciseDetails.runningTarget;

    if (runningTarget != null && (runningTarget.metric == WorkoutMetric.distance || hasDistance)) {
      return true;
    }

    if (hasDistance && (hasTime || hasPace)) return true;
    if (hasTime && exerciseDetails.type == ExerciseType.endurance) return true;

    return exerciseDetails.key?.toLowerCase().contains('run') ?? false;
  }

  @override
  String toString() {
    return 'ProgramExerciseEntity(\nid: $id, \nprogramDayId: $programDayId, \nsets: $sets, \norder: $order, \nexerciseDetails: $exerciseDetails,\n segments:$segments )';
  }
}
