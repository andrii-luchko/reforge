import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_program_exercise_binding.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_source.dart';

class WorkoutExecutionPlan {
  const WorkoutExecutionPlan({
    required this.source,
    required this.exercises,
  });

  factory WorkoutExecutionPlan.fromProgramDay(ProgramDayEntity day) {
    return WorkoutExecutionPlan(
      source: WorkoutSource.program(programDayId: day.id),
      exercises: [
        for (final exercise in day.sortedExercises)
          WorkoutExerciseSpec(
            executionKey: 'program:${day.id}:exercise:${exercise.id}',
            details: exercise.exerciseDetails,
            targetSetCount: exercise.sets,
            segments: exercise.segments,
            programBinding: WorkoutProgramExerciseBinding(
              programDayId: day.id,
              programExerciseId: exercise.id,
              order: exercise.order,
              executionMode: exercise.executionMode,
            ),
          ),
      ],
    );
  }

  factory WorkoutExecutionPlan.adHoc({required List<WorkoutExerciseSpec> exercises}) {
    return WorkoutExecutionPlan(
      source: const WorkoutSource.adHoc(),
      exercises: List.unmodifiable(exercises),
    );
  }

  factory WorkoutExecutionPlan.freeRun({
    required ExerciseDetailsEntity details,
    required String executionKey,
  }) {
    if (details.id != freeRunExerciseId) {
      throw ArgumentError.value(
        details.id,
        'details.id',
        'Free Run requires catalog exercise id $freeRunExerciseId',
      );
    }
    return WorkoutExecutionPlan.adHoc(
      exercises: [
        WorkoutExerciseSpec(
          executionKey: executionKey,
          details: details,
          targetSetCount: null,
          segments: const [],
          programBinding: null,
        ),
      ],
    );
  }

  static const int freeRunExerciseId = 4;

  final WorkoutSource source;
  final List<WorkoutExerciseSpec> exercises;
}
