import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/completed_set_identity.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class TestExerciseSessionRepository implements ExerciseSessionRepository {
  const TestExerciseSessionRepository();

  @override
  Future<Result<WorkoutExerciseSessionEntity>> createWorkoutExerciseSession({
    required int exerciseId,
    required int workoutSessionId,
    required MeasurementSystem system,
    int? workoutProgramExerciseId,
  }) async {
    return Result.success(
      WorkoutExerciseSessionEntity(
        id: workoutProgramExerciseId ?? exerciseId,
        exerciseId: exerciseId,
        workoutSessionId: workoutSessionId,
        workoutProgramExerciseId: workoutProgramExerciseId,
        isSwapped: false,
        swappedExerciseId: null,
        isActive: true,
        notes: null,
        lastCompletedSet: null,
        createdAt: null,
        updatedAt: null,
        sets: const [],
        exercise: null,
        swappedExercise: null,
      ),
    );
  }

  @override
  Future<Result<SwapExerciseSearchPage>> searchSwapExercises({
    String? search,
    int? factionId,
    int page = 1,
    int limit = 20,
  }) async {
    return Result.success((
      exercises: const [],
      pagination: PaginationInfo(page: page, total: 0, limit: limit, pages: 0),
    ));
  }

  @override
  Future<Result<WorkoutExerciseSessionEntity>> swapExercise({
    required int workoutExerciseSessionId,
    required int swappedExerciseId,
    required MeasurementSystem system,
  }) async {
    return Result.success(
      WorkoutExerciseSessionEntity(
        id: workoutExerciseSessionId,
        exerciseId: swappedExerciseId,
        workoutSessionId: 0,
        workoutProgramExerciseId: 0,
        isSwapped: true,
        swappedExerciseId: swappedExerciseId,
        isActive: true,
        notes: null,
        lastCompletedSet: null,
        createdAt: null,
        updatedAt: null,
        sets: const [],
        exercise: null,
        swappedExercise: null,
      ),
    );
  }

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
  Future<Result<CompletedSetIdentity>> completeSet({
    required WorkoutSet set,
    required int exerciseId,
    required int workoutSessionId,
    required int exerciseSessionId,
    required MeasurementSystem system,
    int? workoutProgramExerciseId,
  }) async {
    return Result.success(
      CompletedSetIdentity(
        remoteSetId: set.id,
        clientSetId: set.clientSetId,
      ),
    );
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
