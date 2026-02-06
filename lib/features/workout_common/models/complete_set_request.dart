import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';

part 'complete_set_request.freezed.dart';
part 'complete_set_request.g.dart';

@freezed
sealed class CreateSetSessionRequest with _$CreateSetSessionRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateSetSessionRequest({
    @JsonKey(name: 'exerciseId') required int exerciseId,
    @JsonKey(name: 'workoutProgramExerciseId') required int workoutProgramExerciseId,
    @JsonKey(name: 'workoutSessionId') required int workoutSessionId,

    @JsonKey(name: 'reps') int? reps,
    @JsonKey(name: 'weightKg') double? weightKg,
    @JsonKey(name: 'tier') int? tier,
    @JsonKey(name: 'durationSec') int? durationSec,
    @JsonKey(name: 'angleDeg') double? angleDeg,
    @JsonKey(name: 'speedKmH') double? speedKmH,
    @JsonKey(name: 'distanceM') double? distanceM,
  }) = _CreateSetSessionRequest;

  factory CreateSetSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateSetSessionRequestFromJson(json);

  factory CreateSetSessionRequest.fromWorkoutSet({
    required WorkoutSet set,
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
    required MeasurementSystem system,
  }) {
    double? finalWeightKg;
    if (set.weight != null) {
      finalWeightKg = system == MeasurementSystem.imperial ? MeasureSystemValues.toKg(set.weight!) : set.weight;
    }

    double? finalDistanceM;
    if (set.distance != null) {
      if (system == MeasurementSystem.imperial) {
        final km = MeasureSystemValues.toKm(set.distance!);
        finalDistanceM = km * 1000;
      } else {
        finalDistanceM = set.distance! * 1000;
      }
    }

    double? finalSpeedKmH;
    if (set.pace != null) {
      finalSpeedKmH = system == MeasurementSystem.imperial ? MeasureSystemValues.toKm(set.pace!) : set.pace;
    }

    return CreateSetSessionRequest(
      exerciseId: exerciseId,
      workoutSessionId: workoutSessionId,
      workoutProgramExerciseId: workoutProgramExerciseId,

      reps: set.reps,
      tier: set.selectedTier,
      durationSec: set.time?.inSeconds,
      angleDeg: set.degrees,

      weightKg: finalWeightKg,
      distanceM: finalDistanceM,
      speedKmH: finalSpeedKmH,
    );
  }
}
