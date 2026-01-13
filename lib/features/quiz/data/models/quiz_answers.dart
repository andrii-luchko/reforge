import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/training_level.dart';

part 'quiz_answers.freezed.dart';
part 'quiz_answers.g.dart';

@freezed
sealed class QuizAnswers with _$QuizAnswers {
  const factory QuizAnswers({
    required DateTime dateOfBirth,

    required MeasurementSystem measurementSystem,

    required MainGoal mainGoal,

    required TrainingLevel trainingLevel,

    required int workoutDaysPerWeek,

    required List<int> specificWorkoutDays,

    required Faction mainFaction,

    required Faction secondFaction,
  }) = _QuizAnswers;

  factory QuizAnswers.fromJson(Map<String, dynamic> json) => _$QuizAnswersFromJson(json);
}
