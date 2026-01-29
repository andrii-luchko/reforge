import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_workout_session_request.freezed.dart';
part 'start_workout_session_request.g.dart';

@freezed
sealed class StartWorkoutSessionRequest with _$StartWorkoutSessionRequest {
  @JsonSerializable(includeIfNull: false)
  const factory StartWorkoutSessionRequest({
    @JsonKey(name: 'workoutProgramDayId') required int workoutProgramDayId,
  }) = _StartWorkoutSessionRequest;

  factory StartWorkoutSessionRequest.fromJson(Map<String, dynamic> json) => _$StartWorkoutSessionRequestFromJson(json);
}
