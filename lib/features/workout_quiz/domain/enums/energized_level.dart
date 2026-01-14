import 'package:reforge/generated/i18n/translations.g.dart';

enum EnergizedLevel { veryLow, low, moderate, good, high }

extension EnergizedLevelExtension on EnergizedLevel {
  String title(Translations t) {
    switch (this) {
      case EnergizedLevel.veryLow:
        return t.workout_quiz.steps.energized_level.very_low;
      case EnergizedLevel.low:
        return t.workout_quiz.steps.energized_level.low;
      case EnergizedLevel.moderate:
        return t.workout_quiz.steps.energized_level.moderate;
      case EnergizedLevel.good:
        return t.workout_quiz.steps.energized_level.good;
      case EnergizedLevel.high:
        return t.workout_quiz.steps.energized_level.high;
    }
  }
}
