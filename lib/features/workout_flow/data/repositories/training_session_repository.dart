// ignore_for_file: prefer_match_file_name
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_common/models/complete_set_request.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_flow/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_flow/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_flow/data/models/workout_summary.dart';
import 'package:reforge/features/workout_flow/data/requests/complete_workout_session_request.dart';
import 'package:reforge/features/workout_flow/data/requests/start_workout_session_request.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_flow/domain/repositories/training_session_repository.dart';

@Injectable(as: TrainingSessionRepository)
class TrainingSessionRepositoryImpl with RepositoryErrorHandler implements TrainingSessionRepository {
  TrainingSessionRepositoryImpl(
    this._apiClient,
    this._userSessionService,
  );

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  @override
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day) async {
    try {
      final response = await makeRequest(
        () => _apiClient.getWorkoutByDay(day),
        label: 'getWorkoutByDay',
      );
      return response.data.isEmpty ? const Result.success(null) : Result.success(response.data.first.toEntity());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  MeasurementSystem? getUserMeasurementSystem() {
    final measurementSystem = _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (u) => u.measurementSystem,
    );

    return measurementSystem;
  }

  @override
  int? getUserCurrentProgramDayId() {
    final currentProgramDayId = _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (u) => u.currentProgramDayId,
    );
    return currentProgramDayId;
  }

  @override
  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId) async {
    try {
      final result = await _apiClient.getWorkoutDetails(workoutSessionId);
      logger.d(result);
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
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
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<WorkoutSession>> startWorkoutSession(int programId) async {
    try {
      final response = await makeRequest(
        () => _apiClient.starWorkoutSession(StartWorkoutSessionRequest(workoutProgramDayId: programId)),
        label: 'startWorkoutSession',
      );

      logger.d(response);

      return Result.success(response.data);
    } on Exception catch (e) {
      return Result.error(e);
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

      if (data == null) {
        return const Result.success(null);
      } else {
        final list = data.sets?.map((set) => set.toWorkoutSet(system)).toList();
        final notes = data.notes;

        return Result.success((notes: notes, sets: list));
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<WorkoutSessionSummaryEntity>> endWorkoutSession({
    required WorkoutSessionStatus status,
    required int workoutSessionId,
    required int workoutSessionDuration,
  }) async {
    try {
      final request = CompleteWorkoutSessionRequest(status: status, durationInSeconds: workoutSessionDuration);
      final response = await makeRequest(
        () => _apiClient.completeWorkoutSession(workoutSessionId, request),
        label: 'endWorkoutSession',
      );
      return Result.success(response.data.toEntity());
    } on Exception catch (e) {
      return Result.error(e);
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
    } on Exception catch (e) {
      return Result.error(e);
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
        () => _apiClient.saveExerciseNotes(workoutSessionId, workoutProgramExerciseId, exerciseId, note),
        label: 'saveWorkoutNote',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
