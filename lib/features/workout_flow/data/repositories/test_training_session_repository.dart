import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_flow/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_flow/data/mock/mocked_day.dart';
import 'package:reforge/features/workout_flow/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_flow/domain/repositories/training_session_repository.dart';

class TestTrainingSessionRepository implements TrainingSessionRepository {
  const TestTrainingSessionRepository();

  @override
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day) async {
    return Result.success(parsedMockedDay.toEntity());
  }

  @override
  MeasurementSystem? getUserMeasurementSystem() {
    return MeasurementSystem.metric;
  }

  @override
  int? getUserCurrentProgramDayId() {
    return 1;
  }

  @override
  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId) async {
    try {
      return Result.success(
        WorkoutSession(
          id: 1,
          userId: 1,
          workoutProgramDayId: parsedMockedDay.id,
          duration: 0,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
        ),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<WorkoutSessionDetailsDTO>> getWorkoutSessionDetails(int sessionId) async {
    // Returns an empty active session — no recorded exercise sets
    return Result.success(
      WorkoutSessionDetailsDTO(
        id: sessionId,
        workoutProgramDayId: parsedMockedDay.id,
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
        id: 1,
        userId: 1,
        workoutProgramDayId: workoutProgramDayId,
        duration: 0,
        status: WorkoutSessionStatus.active,
        totalXpEarned: 0,
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
        WorkoutSet(
          id: 1,
          setNumber: 1,
          reps: 10,
          weight: 100,
          isDone: true,
        ),
        WorkoutSet(
          id: 2,
          setNumber: 2,
          reps: 8,
          weight: 110,
          isDone: true,
        ),
      ],
    ));
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
