import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/domain/enums/gender.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/training_level.dart';

part 'patch_profile_request.freezed.dart';
part 'patch_profile_request.g.dart';

@freezed
sealed class PatchProfileRequest with _$PatchProfileRequest {
  @JsonSerializable(
    explicitToJson: true,
    includeIfNull: false,
  )
  const factory PatchProfileRequest({
    String? username,
    String? avatarUrl,

    @JsonKey(name: 'email') String? emailAddress,
    @JsonKey(name: 'factionId') int? mainFaction,
    @JsonKey(name: 'secondaryFactionId') int? secondFaction,

    @JsonKey(name: 'birthDate', toJson: _dateToJson) DateTime? dateOfBirth,

    @JsonKey(name: 'measurementSystem') MeasurementSystem? measurementSystem,
    @JsonKey(name: 'trainingGoal') MainGoal? mainGoal,
    @JsonKey(name: 'experiencedLevel') TrainingLevel? trainingLevel,
    @JsonKey(name: 'workoutsPerWeek') int? workoutDaysPerWeek,
    @JsonKey(name: 'specificDays') List<int>? specificWorkoutDays,

    @JsonKey(name: 'bodyweight') int? bodyWeight,

    @JsonKey(name: 'remindersEnabled') bool? remindersEnabled,
    @JsonKey(name: 'announcementsEnabled') bool? announcementsEnabled,

    Gender? gender,
  }) = _PatchProfileRequest;

  factory PatchProfileRequest.fromJson(Map<String, dynamic> json) => _$PatchProfileRequestFromJson(json);
}

String? _dateToJson(DateTime? date) {
  if (date == null) return null;
  return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
