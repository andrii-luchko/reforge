import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/training_session/data/enums/workout_session_status.dart';

part 'complete_workout_session_request.freezed.dart';
part 'complete_workout_session_request.g.dart';

@freezed
sealed class CompleteWorkoutSessionRequest with _$CompleteWorkoutSessionRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CompleteWorkoutSessionRequest({
    @JsonKey(name: 'status') required WorkoutSessionStatus status,
    @JsonKey(name: 'durationInSeconds') required int durationInSeconds,
  }) = _CompleteWorkoutSessionRequest;

  factory CompleteWorkoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteWorkoutSessionRequestFromJson(json);
}
