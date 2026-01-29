import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/training_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/training_session/data/models/program_day.dart';
import 'package:reforge/features/training_session/data/models/workout_session.dart';
import 'package:reforge/features/training_session/data/models/workout_set.dart';
import 'package:reforge/features/training_session/data/models/workout_summary.dart';

abstract interface class TrainingSessionRepository {
  Future<Result<ProgramDay>> getWorkoutByDay(int day);

  MeasurementSystem? getUserMeasurementSystem();

  int? getUserCurrentProgramDayId();

  Future<Result<WorkoutSession>> startWorkoutSession(int workoutProgramDayId);

  Future<Result<WorkoutSessionSummary>> endWorkoutSession({
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
