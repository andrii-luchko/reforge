// ignore_for_file: prefer_match_file_name

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/exercise_session/data/models/complete_set_request.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

@Injectable(as: ExerciseSessionRepository)
class ExerciseSessionRepositoryImpl with RepositoryErrorHandler implements ExerciseSessionRepository {
  ExerciseSessionRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

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
