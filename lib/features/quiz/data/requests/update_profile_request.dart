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
  @JsonSerializable(explicitToJson: true)
  const factory UpdateProfileRequest({
    @JsonKey(name: 'primaryFaction') required Faction mainFaction,
    @JsonKey(name: 'secondaryFaction') required Faction secondFaction,
    @JsonKey(name: 'birthDate') required DateTime dateOfBirth,
    @JsonKey(name: 'measurementSystem') required MeasurementSystem measurementSystem,
    @JsonKey(name: 'trainingGoal') required MainGoal mainGoal,
    @JsonKey(name: 'experiencedLevel') required TrainingLevel trainingLevel,
    @JsonKey(name: 'workoutsPerWeek') required int workoutDaysPerWeek,
    @JsonKey(name: 'specificDays') required List<int> specificWorkoutDays,
    double? bodyweight,
    @Default(Gender.other) Gender gender,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);

  factory UpdateProfileRequest.fromQuizAnswers({
    required QuizAnswers answers,
    double? bodyweight,
  }) {
    return UpdateProfileRequest(
      bodyweight: bodyweight,
      mainFaction: answers.mainFaction,
      secondFaction: answers.secondFaction,
      dateOfBirth: answers.dateOfBirth,
      measurementSystem: answers.measurementSystem,
      mainGoal: answers.mainGoal,
      trainingLevel: answers.trainingLevel,
      workoutDaysPerWeek: answers.workoutDaysPerWeek,
      specificWorkoutDays: answers.specificWorkoutDays,
    );
  }
}
