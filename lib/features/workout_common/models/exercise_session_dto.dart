import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';

part 'exercise_session_dto.freezed.dart';
part 'exercise_session_dto.g.dart';

@freezed
sealed class ExerciseSessionDTO with _$ExerciseSessionDTO {
  const factory ExerciseSessionDTO({
    required int id,
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required bool isActive,
    String? notes,
    List<ExerciseSetDTO>? sets,
    ExerciseDetailsDTO? exercise,
  }) = _ExerciseSessionDTO;

  factory ExerciseSessionDTO.fromJson(Map<String, dynamic> json) => _$ExerciseSessionDTOFromJson(json);
}

@freezed
sealed class ExerciseSetDTO with _$ExerciseSetDTO {
  const ExerciseSetDTO._();

  const factory ExerciseSetDTO({
    required int id,
    required int exerciseId,
    required int exerciseSessionId,
    String? tier,
    int? reps,
    int? durationSec,
    double? weightKg,
    double? angleDeg,
    double? speedKmH,
    int? distanceM,
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
      setNumber: setNumber,
      reps: reps,
      selectedTier: tier != null ? int.tryParse(tier!) : null,
      weight: finalWeight,
      distance: finalDistance,
      pace: finalSpeed,
      degrees: angleDeg,
      time: durationSec != null ? Duration(seconds: durationSec!) : null,
    );
  }
}
