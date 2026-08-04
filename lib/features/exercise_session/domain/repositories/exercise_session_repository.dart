import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/completed_set_identity.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

typedef SwapExerciseSearchPage = ({
  List<ExerciseDetailsEntity> exercises,
  PaginationInfo pagination,
});

abstract interface class ExerciseSessionRepository {
  Future<Result<WorkoutExerciseSessionEntity>> createWorkoutExerciseSession({
    required int exerciseId,
    required int workoutSessionId,
    required MeasurementSystem system,
    int? workoutProgramExerciseId,
  });

  Future<Result<SwapExerciseSearchPage>> searchSwapExercises({
    String? search,
    int? factionId,
    int page = 1,
    int limit = 20,
  });

  Future<Result<WorkoutExerciseSessionEntity>> swapExercise({
    required int workoutExerciseSessionId,
    required int swappedExerciseId,
    required MeasurementSystem system,
  });

  Future<Result<CompletedSetIdentity>> completeSet({
    required int exerciseId,
    required int workoutSessionId,
    required int exerciseSessionId,
    required MeasurementSystem system,
    required WorkoutSet set,
    int? workoutProgramExerciseId,
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
