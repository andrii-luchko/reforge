import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_quiz/domain/enums/body_feel.dart';
import 'package:reforge/features/workout_quiz/domain/enums/energized_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/hydrated_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/sleep_quality.dart';
import 'package:reforge/features/workout_quiz/domain/enums/stress_level.dart';

part 'workout_quiz_answers.freezed.dart';
part 'workout_quiz_answers.g.dart';

@freezed
sealed class WorkoutQuizAnswers with _$WorkoutQuizAnswers {
  const factory WorkoutQuizAnswers({
    required SleepQuality sleepQuality,
    required EnergizedLevel energizedLevel,
    required StressLevel stressLevel,
    required BodyFeel bodyFeel,
    required HydratedLevel hydratedLevel,
    required bool hasEatenRecently,
    required bool isMorningSession,
  }) = _WorkoutQuizAnswers;

  factory WorkoutQuizAnswers.fromJson(Map<String, dynamic> json) => _$WorkoutQuizAnswersFromJson(json);
}
