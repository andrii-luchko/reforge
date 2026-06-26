import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_flow/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';

abstract interface class TrainingSessionRepository {
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day);

  MeasurementSystem? getUserMeasurementSystem();

  int? getUserCurrentProgramDayId();

  Future<Result<WorkoutSession?>> getWorkoutSession(int workoutSessionId);

  /// Fetches the full session details including all recorded exercise sessions and sets.
  /// Used for restoring an interrupted workout.
  Future<Result<WorkoutSessionDetailsDTO>> getWorkoutSessionDetails(int sessionId);

  Future<Result<WorkoutSession>> startWorkoutSession(int workoutProgramDayId);

  Future<Result<WorkoutSessionSummaryEntity>> endWorkoutSession({
    required WorkoutSessionStatus status,
    required int workoutSessionId,
    required int workoutSessionDuration,
  });

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
