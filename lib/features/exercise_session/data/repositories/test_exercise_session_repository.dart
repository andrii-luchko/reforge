import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class TestExerciseSessionRepository implements ExerciseSessionRepository {
  const TestExerciseSessionRepository();

  @override
  Future<Result<({String? notes, List<WorkoutSet>? sets})?>> getPreviousResults({
    required int workoutSessionId,
    required int programExerciseId,
    required MeasurementSystem system,
  }) async {
    return Result.success((
      notes: 'Test previous notes',
      sets: [
        WorkoutSet(id: 1, setNumber: 1, reps: 10, weight: 100, isDone: true),
        WorkoutSet(id: 2, setNumber: 2, reps: 8, weight: 110, isDone: true),
      ],
    ));
  }

  @override
  Future<Result<void>> completeSet({
    required WorkoutSet set,
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required MeasurementSystem system,
  }) async {
    return const Result.success(null);
  }

  @override
  Future<Result<void>> saveWorkoutNote({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required String note,
  }) async {
    return const Result.success(null);
  }
}
