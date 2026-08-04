// ignore_for_file: prefer_match_file_name

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/exercise_session/data/models/complete_set_request.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/data/requests/create_workout_exercise_session_request.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_request.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_search_request.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

@Injectable(as: ExerciseSessionRepository)
class ExerciseSessionRepositoryImpl with RepositoryErrorHandler implements ExerciseSessionRepository {
  ExerciseSessionRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<WorkoutExerciseSessionEntity>> createWorkoutExerciseSession({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required MeasurementSystem system,
  }) async {
    try {
      final response = await makeRequest(
        () => _apiClient.createWorkoutExerciseSession(
          CreateWorkoutExerciseSessionRequest(
            exerciseId: exerciseId,
            workoutSessionId: workoutSessionId,
            workoutProgramExerciseId: workoutProgramExerciseId,
          ),
        ),
        label: 'createWorkoutExerciseSession',
      );
      return Result.success(response.data.toEntity(system));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<SwapExerciseSearchPage>> searchSwapExercises({
    String? search,
    int? factionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await makeRequest(
        () => _apiClient.searchSwapExercises(
          SwapExerciseSearchRequest(
            search: search,
            factionId: factionId,
            page: page,
            limit: limit,
          ),
        ),
        label: 'searchSwapExercises',
      );
      return Result.success((
        exercises: response.data.map((exercise) => exercise.toEntity()).toList(),
        pagination: response.meta.pagination,
      ));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<WorkoutExerciseSessionEntity>> swapExercise({
    required int workoutExerciseSessionId,
    required int swappedExerciseId,
    required MeasurementSystem system,
  }) async {
    try {
      final response = await makeRequest(
        () => _apiClient.swapWorkoutExercise(
          workoutExerciseSessionId,
          SwapExerciseRequest(swappedExerciseId: swappedExerciseId),
        ),
        label: 'swapExercise',
      );
      return Result.success(response.data.toEntity(system));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<({String? notes, List<WorkoutSet>? sets})?>> getPreviousResults({
    required int workoutSessionId,
    required int programExerciseId,
    required MeasurementSystem system,
  }) async {
    try {
      final response = await makeRequest(
        () => _apiClient.getPreviousExercise(workoutSessionId, programExerciseId),
        label: 'getPreviousResults',
      );
      final data = response.data;

      if (data == null) return const Result.success(null);

      final sets = data.sets.map((set) => set.toWorkoutSet(system)).toList();
      return Result.success((notes: data.notes, sets: sets));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<void>> completeSet({
    required WorkoutSet set,
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required MeasurementSystem system,
  }) async {
    try {
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: set,
        exerciseId: exerciseId,
        workoutProgramExerciseId: workoutProgramExerciseId,
        workoutSessionId: workoutSessionId,
        system: system,
      );
      await makeRequest(
        () => _apiClient.completeSet(request),
        label: 'completeSet',
      );
      return const Result.success(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<void>> saveWorkoutNote({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required String note,
  }) async {
    try {
      await makeRequest(
        () => _apiClient.saveExerciseNotes(
          workoutSessionId,
          workoutProgramExerciseId,
          exerciseId,
          note,
        ),
        label: 'saveWorkoutNote',
      );
      return const Result.success(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
