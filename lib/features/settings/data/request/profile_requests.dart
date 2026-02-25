import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

part 'profile_requests.freezed.dart';
part 'profile_requests.g.dart';

@freezed
sealed class UpdateFactionsRequest with _$UpdateFactionsRequest {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory UpdateFactionsRequest({
    @JsonKey(name: 'factionId') int? mainFaction,
    @JsonKey(name: 'secondaryFactionId') int? secondFaction,
  }) = _UpdateFactionsRequest;

  factory UpdateFactionsRequest.fromJson(Map<String, dynamic> json) => _$UpdateFactionsRequestFromJson(json);
}

@freezed
sealed class UpdateMeasurementSystemRequest with _$UpdateMeasurementSystemRequest {
  const factory UpdateMeasurementSystemRequest({
    @JsonKey(name: 'measurementSystem') MeasurementSystem? measurementSystem,
  }) = _UpdateMeasurementSystemRequest;

  factory UpdateMeasurementSystemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeasurementSystemRequestFromJson(json);
}

@freezed
sealed class UpdateWorkoutDaysRequest with _$UpdateWorkoutDaysRequest {
  @JsonSerializable(
    explicitToJson: true,
    includeIfNull: false,
  )
  const factory UpdateWorkoutDaysRequest({
    @JsonKey(name: 'workoutsPerWeek') int? workoutDaysPerWeek,
    @JsonKey(name: 'specificDays') List<int>? specificWorkoutDays,
  }) = _UpdateWorkoutDaysRequest;

  factory UpdateWorkoutDaysRequest.fromJson(Map<String, dynamic> json) => _$UpdateWorkoutDaysRequestFromJson(json);
}

@freezed
sealed class UpdateNotificationsRequest with _$UpdateNotificationsRequest {
  @JsonSerializable(
    explicitToJson: true,
    includeIfNull: false,
  )
  const factory UpdateNotificationsRequest({
    @JsonKey(name: 'remindersEnabled') bool? remindersEnabled,
    @JsonKey(name: 'announcementsEnabled') bool? announcementsEnabled,
  }) = _UpdateNotificationsRequest;

  factory UpdateNotificationsRequest.fromJson(Map<String, dynamic> json) => _$UpdateNotificationsRequestFromJson(json);
}
