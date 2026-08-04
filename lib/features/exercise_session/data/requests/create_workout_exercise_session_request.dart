import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_workout_exercise_session_request.freezed.dart';
part 'create_workout_exercise_session_request.g.dart';

@freezed
sealed class CreateWorkoutExerciseSessionRequest with _$CreateWorkoutExerciseSessionRequest {
  const CreateWorkoutExerciseSessionRequest._();

  @JsonSerializable(includeIfNull: false)
  const factory CreateWorkoutExerciseSessionRequest({
    required int exerciseId,
    required int workoutSessionId,
    int? workoutProgramExerciseId,
  }) = _CreateWorkoutExerciseSessionRequest;

  factory CreateWorkoutExerciseSessionRequest.program({
    required int exerciseId,
    required int workoutSessionId,
    required int workoutProgramExerciseId,
  }) => CreateWorkoutExerciseSessionRequest(
    exerciseId: exerciseId,
    workoutSessionId: workoutSessionId,
    workoutProgramExerciseId: workoutProgramExerciseId,
  );

  factory CreateWorkoutExerciseSessionRequest.adHoc({
    required int exerciseId,
    required int workoutSessionId,
  }) => CreateWorkoutExerciseSessionRequest(
    exerciseId: exerciseId,
    workoutSessionId: workoutSessionId,
  );

  factory CreateWorkoutExerciseSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutExerciseSessionRequestFromJson(json);
}
