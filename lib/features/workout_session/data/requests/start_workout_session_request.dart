import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_workout_session_request.freezed.dart';
part 'start_workout_session_request.g.dart';

@freezed
sealed class StartWorkoutSessionRequest with _$StartWorkoutSessionRequest {
  const StartWorkoutSessionRequest._();

  @JsonSerializable(includeIfNull: false)
  const factory StartWorkoutSessionRequest({
    @JsonKey(name: 'workoutProgramDayId') int? workoutProgramDayId,
  }) = _StartWorkoutSessionRequest;

  factory StartWorkoutSessionRequest.program({required int workoutProgramDayId}) =>
      StartWorkoutSessionRequest(workoutProgramDayId: workoutProgramDayId);

  factory StartWorkoutSessionRequest.adHoc() => const StartWorkoutSessionRequest();

  factory StartWorkoutSessionRequest.fromJson(Map<String, dynamic> json) => _$StartWorkoutSessionRequestFromJson(json);
}
