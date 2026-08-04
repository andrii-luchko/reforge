import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/data/mock/mocked_day.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

class TestWorkoutSessionRepository implements WorkoutSessionRepository {
  const TestWorkoutSessionRepository();

  @override
  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId) async {
    return Result.success(
      WorkoutSession(
        id: workoutSessionId,
        userId: 1,
        workoutProgramDayId: mockProgramDay.id,
        duration: 0,
        status: WorkoutSessionStatus.active,
        totalXpEarned: 0,
      ),
    );
  }

  @override
  Future<Result<WorkoutSessionDetailsDTO>> getWorkoutSessionDetails(int sessionId) async {
    return Result.success(
      WorkoutSessionDetailsDTO(
        id: sessionId,
        workoutProgramDayId: mockProgramDay.id,
        duration: 0,
        status: WorkoutSessionStatus.active,
        totalXpEarned: 0,
        workoutSessions: const [],
      ),
    );
  }

  @override
  Future<Result<WorkoutSession>> startWorkoutSession(int workoutProgramDayId) async {
    return Result.success(
      WorkoutSession(
        id: 99,
        userId: 1,
        workoutProgramDayId: workoutProgramDayId,
        duration: 0,
        status: WorkoutSessionStatus.active,
        totalXpEarned: 0,
      ),
    );
  }

  @override
  Future<Result<WorkoutSessionSummaryEntity>> endWorkoutSession({
    required WorkoutSessionStatus status,
    required int workoutSessionId,
    required int workoutSessionDuration,
  }) async {
    return Result.success(
      WorkoutSessionSummaryEntity(
        id: workoutSessionId,
        duration: workoutSessionDuration,
        totalXpEarned: 150,
        earnedMilestones: const [],
        isLevelUp: false,
        currentLevel: 5,
      ),
    );
  }
}
