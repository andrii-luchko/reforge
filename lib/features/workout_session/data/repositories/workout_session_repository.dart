// ignore_for_file: prefer_match_file_name

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/data/models/workout_summary.dart';
import 'package:reforge/features/workout_session/data/requests/complete_workout_session_request.dart';
import 'package:reforge/features/workout_session/data/requests/start_workout_session_request.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

@Injectable(as: WorkoutSessionRepository)
class WorkoutSessionRepositoryImpl with RepositoryErrorHandler implements WorkoutSessionRepository {
  WorkoutSessionRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId) async {
    try {
      final result = await _apiClient.getWorkoutDetails(workoutSessionId);
      logger.d(result);
      return const Result.success(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<WorkoutSessionDetailsDTO?>> getWorkoutSessionDetails(int sessionId) async {
    try {
      final response = await makeRequest(
        () => _apiClient.getWorkoutDetails(sessionId),
        label: 'getWorkoutSessionDetails',
      );
      return Result.success(response.data);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<WorkoutSession>> startWorkoutSession(int workoutProgramDayId) async {
    try {
      final response = await makeRequest(
        () => _apiClient.starWorkoutSession(
          StartWorkoutSessionRequest(workoutProgramDayId: workoutProgramDayId),
        ),
        label: 'startWorkoutSession',
      );
      logger.d(response);
      return Result.success(response.data);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<WorkoutSessionSummaryEntity>> endWorkoutSession({
    required WorkoutSessionStatus status,
    required int workoutSessionId,
    required int workoutSessionDuration,
  }) async {
    try {
      final request = CompleteWorkoutSessionRequest(
        status: status,
        durationInSeconds: workoutSessionDuration,
      );
      final response = await makeRequest(
        () => _apiClient.completeWorkoutSession(workoutSessionId, request),
        label: 'endWorkoutSession',
      );
      return Result.success(response.data.toEntity());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
