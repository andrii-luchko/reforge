import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';

abstract interface class WorkoutSessionRepository {
  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId);

  Future<Result<WorkoutSessionDetailsDTO?>> getWorkoutSessionDetails(int sessionId);

  Future<Result<WorkoutSession>> startWorkoutSession(int workoutProgramDayId);

  Future<Result<WorkoutSession>> startAdHocWorkoutSession();

  Future<Result<WorkoutSessionSummaryEntity>> endWorkoutSession({
    required WorkoutSessionStatus status,
    required int workoutSessionId,
    required int workoutSessionDuration,
  });
}
