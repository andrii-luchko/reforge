import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';

part 'workout_exercise_session_dto.freezed.dart';
part 'workout_exercise_session_dto.g.dart';

@freezed
sealed class WorkoutExerciseSessionDTO with _$WorkoutExerciseSessionDTO {
  const WorkoutExerciseSessionDTO._();

  const factory WorkoutExerciseSessionDTO({
    required int id,
    required int exerciseId,
    required int workoutSessionId,
    int? workoutProgramExerciseId,
    @Default(false) bool isSwapped,
    int? swappedExerciseId,
    @Default(true) bool isActive,
    String? notes,
    int? lastCompletedSet,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<ExerciseSetDTO> sets,
    ExerciseDetailsDTO? exercise,
    ExerciseDetailsDTO? swappedExercise,
  }) = _WorkoutExerciseSessionDTO;

  factory WorkoutExerciseSessionDTO.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseSessionDTOFromJson(json);

  WorkoutExerciseSessionEntity toEntity(MeasurementSystem system) {
    return WorkoutExerciseSessionEntity(
      id: id,
      exerciseId: exerciseId,
      workoutSessionId: workoutSessionId,
      workoutProgramExerciseId: workoutProgramExerciseId,
      isSwapped: isSwapped,
      swappedExerciseId: swappedExerciseId,
      isActive: isActive,
      notes: notes,
      lastCompletedSet: lastCompletedSet,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sets: sets.map((set) => set.toWorkoutSet(system)).toList(),
      exercise: exercise?.toEntity(),
      swappedExercise: swappedExercise?.toEntity(),
    );
  }
}

@freezed
sealed class ExerciseSetDTO with _$ExerciseSetDTO {
  const ExerciseSetDTO._();

  const factory ExerciseSetDTO({
    required int id,
    required int exerciseId,
    required int exerciseSessionId,
    @JsonKey(name: 'idempotencyKey') String? clientSetId,
    int? programSegmentId,
    int? tier,
    int? reps,
    int? durationSec,
    double? weightKg,
    double? angleDeg,
    double? speedKmH,
    double? distanceM,
    int? setNumber,
  }) = _ExerciseSetDTO;

  factory ExerciseSetDTO.fromJson(Map<String, dynamic> json) => _$ExerciseSetDTOFromJson(json);

  WorkoutSet toWorkoutSet(MeasurementSystem system) {
    double? finalWeight;
    if (weightKg != null) {
      finalWeight = system == MeasurementSystem.imperial ? MeasureSystemValues.toPounds(weightKg!) : weightKg;
    }

    double? finalDistance;
    if (distanceM != null) {
      final distanceInKm = distanceM! / 1000;
      finalDistance = system == MeasurementSystem.imperial ? MeasureSystemValues.toMiles(distanceInKm) : distanceInKm;
    }

    double? finalSpeed;
    if (speedKmH != null) {
      finalSpeed = system == MeasurementSystem.imperial ? MeasureSystemValues.toMiles(speedKmH!) : speedKmH;
    }

    return WorkoutSet(
      id: id,
      clientSetId: clientSetId,
      setNumber: setNumber,
      reps: reps,
      selectedTier: tier,
      weight: finalWeight,
      distance: finalDistance,
      speed: finalSpeed,
      pace: finalSpeed != null && finalSpeed > 0 ? 60 / finalSpeed : null,
      degrees: angleDeg,
      time: durationSec != null ? Duration(seconds: durationSec!) : null,
      programSegmentId: programSegmentId,
    );
  }
}
