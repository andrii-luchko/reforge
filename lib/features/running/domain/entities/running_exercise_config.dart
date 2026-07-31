import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';

class RunningExerciseConfig {
  const RunningExerciseConfig({
    required this.workoutSessionId,
    required this.workoutProgramExerciseId,
    required this.exercise,
    required this.segments,
  });

  final int workoutSessionId;
  final int workoutProgramExerciseId;
  final ExerciseDetailsEntity exercise;
  final List<ExerciseSegmentEntity> segments;

  bool get isFreeRun => segments.isEmpty;
}
