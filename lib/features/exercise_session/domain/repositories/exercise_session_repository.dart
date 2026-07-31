import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

abstract interface class ExerciseSessionRepository {
  Future<Result<void>> completeSet({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required MeasurementSystem system,
    required WorkoutSet set,
  });

  Future<Result<({String? notes, List<WorkoutSet>? sets})?>> getPreviousResults({
    required int workoutSessionId,
    required int programExerciseId,
    required MeasurementSystem system,
  });

  Future<Result<void>> saveWorkoutNote({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required String note,
  });
}
