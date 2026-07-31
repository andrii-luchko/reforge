import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_workout_exercise_session_request.freezed.dart';
part 'create_workout_exercise_session_request.g.dart';

@freezed
sealed class CreateWorkoutExerciseSessionRequest with _$CreateWorkoutExerciseSessionRequest {
  const factory CreateWorkoutExerciseSessionRequest({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
  }) = _CreateWorkoutExerciseSessionRequest;

  factory CreateWorkoutExerciseSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutExerciseSessionRequestFromJson(json);
}
