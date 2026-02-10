import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/gender.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/training_level.dart';

part 'update_profile_request.freezed.dart';
part 'update_profile_request.g.dart';

@freezed
sealed class UpdateProfileRequest with _$UpdateProfileRequest {
  @JsonSerializable(
    explicitToJson: true,
    includeIfNull: false,
  )
  const factory UpdateProfileRequest({
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'avatarUrl') String? avatarUrl,
    @JsonKey(name: 'primaryFaction') Faction? mainFaction,
    @JsonKey(name: 'secondaryFaction') Faction? secondFaction,

    @JsonKey(name: 'birthDate') DateTime? dateOfBirth,

    @JsonKey(name: 'measurementSystem') MeasurementSystem? measurementSystem,
    @JsonKey(name: 'trainingGoal') MainGoal? mainGoal,
    @JsonKey(name: 'experiencedLevel') TrainingLevel? trainingLevel,
    @JsonKey(name: 'workoutsPerWeek') int? workoutDaysPerWeek,
    @JsonKey(name: 'specificDays') List<int>? specificWorkoutDays,
    @JsonKey(name: 'bodyweight') int? bodyWeight,
    Gender? gender,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);

  factory UpdateProfileRequest.fromQuizAnswers({
    required QuizAnswers answers,
  }) {
    return UpdateProfileRequest(
      bodyWeight: answers.bodyWeight,
      mainFaction: answers.mainFaction,
      secondFaction: answers.secondFaction,
      dateOfBirth: answers.dateOfBirth,
      measurementSystem: answers.measurementSystem,
      mainGoal: answers.mainGoal,
      trainingLevel: answers.trainingLevel,
      workoutDaysPerWeek: answers.workoutDaysPerWeek,
      specificWorkoutDays: answers.specificWorkoutDays,
      gender: Gender.other,
    );
  }
}
