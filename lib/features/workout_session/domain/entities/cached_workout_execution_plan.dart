import 'dart:convert';

import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_source.dart';

class CachedWorkoutExerciseSpec {
  const CachedWorkoutExerciseSpec({
    required this.executionKey,
    required this.exerciseId,
    required this.position,
    this.targetSetCount,
    this.workoutProgramExerciseId,
  });

  final String executionKey;
  final int exerciseId;
  final int position;
  final int? targetSetCount;
  final int? workoutProgramExerciseId;
}

class CachedWorkoutExecutionPlan {
  const CachedWorkoutExecutionPlan({
    required this.isProgram,
    required this.exercises,
    this.programDayId,
  });

  factory CachedWorkoutExecutionPlan.fromPlan(WorkoutExecutionPlan plan) {
    final source = plan.source;
    return CachedWorkoutExecutionPlan(
      isProgram: source is ProgramWorkoutSource,
      programDayId: source is ProgramWorkoutSource ? source.programDayId : null,
      exercises: [
        for (var index = 0; index < plan.exercises.length; index++)
          CachedWorkoutExerciseSpec(
            executionKey: plan.exercises[index].executionKey,
            exerciseId: plan.exercises[index].exerciseId,
            position: index,
            targetSetCount: plan.exercises[index].targetSetCount,
            workoutProgramExerciseId: plan.exercises[index].workoutProgramExerciseId,
          ),
      ],
    );
  }

  factory CachedWorkoutExecutionPlan.decode(String json) {
    final value = jsonDecode(json) as Map<String, Object?>;
    final rawExercises = value['exercises'] as List<Object?>? ?? const [];
    return CachedWorkoutExecutionPlan(
      isProgram: value['source'] == 'program',
      programDayId: value['programDayId'] as int?,
      exercises: [
        for (final raw in rawExercises)
          if (raw case final Map<String, Object?> exercise)
            CachedWorkoutExerciseSpec(
              executionKey: exercise['executionKey']! as String,
              exerciseId: exercise['exerciseId']! as int,
              position: exercise['position']! as int,
              targetSetCount: exercise['targetSetCount'] as int?,
              workoutProgramExerciseId: exercise['workoutProgramExerciseId'] as int?,
            ),
      ],
    );
  }

  final bool isProgram;
  final int? programDayId;
  final List<CachedWorkoutExerciseSpec> exercises;

  String encode() {
    return jsonEncode({
      'version': 1,
      'source': isProgram ? 'program' : 'adHoc',
      'programDayId': programDayId,
      'exercises': [
        for (final exercise in exercises)
          {
            'executionKey': exercise.executionKey,
            'exerciseId': exercise.exerciseId,
            'position': exercise.position,
            'targetSetCount': exercise.targetSetCount,
            'workoutProgramExerciseId': exercise.workoutProgramExerciseId,
          },
      ],
    });
  }
}
