import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';
import 'package:reforge/features/workout_quiz/domain/enums/body_feel.dart';
import 'package:reforge/features/workout_quiz/domain/enums/energized_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/hydrated_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/sleep_quality.dart';
import 'package:reforge/features/workout_quiz/domain/enums/stress_level.dart';

part 'workout_quiz_request.freezed.dart';
part 'workout_quiz_request.g.dart';

@freezed
sealed class WorkoutQuizRequest with _$WorkoutQuizRequest {
  @JsonSerializable(explicitToJson: true)
  const factory WorkoutQuizRequest({
    @JsonKey(name: 'userId') required int userId,
    @JsonKey(name: 'sleepQuality') required SleepQuality sleepQuality,
    @JsonKey(name: 'energyLevels') required EnergizedLevel energyLevels,
    @JsonKey(name: 'stressLevels') required StressLevel stressLevels,
    @JsonKey(name: 'sorenessFatigue') required BodyFeel sorenessFatigue,
    @JsonKey(name: 'hydration') required HydratedLevel hydration,
    @JsonKey(name: 'hasEaten') required bool hasEaten,
    @JsonKey(name: 'isMorningSession') required bool isMorningSession,
  }) = _WorkoutQuizRequest;

  factory WorkoutQuizRequest.fromJson(Map<String, dynamic> json) => _$WorkoutQuizRequestFromJson(json);

  factory WorkoutQuizRequest.fromWorkoutQuizAnswers({
    required int userId,
    required WorkoutQuizAnswers answers,
  }) {
    return WorkoutQuizRequest(
      userId: userId,
      sleepQuality: answers.sleepQuality,
      energyLevels: answers.energizedLevel,
      stressLevels: answers.stressLevel,
      sorenessFatigue: answers.bodyFeel,
      hydration: answers.hydratedLevel,
      hasEaten: answers.hasEatenRecently,
      isMorningSession: answers.isMorningSession,
    );
  }
}
