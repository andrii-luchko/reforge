import 'package:json_annotation/json_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum StressLevel {
  @JsonValue(1)
  veryStressed,
  @JsonValue(2)
  stressed,
  @JsonValue(3)
  neutral,
  @JsonValue(4)
  calm,
  @JsonValue(5)
  veryRelaxed,
}

extension StressLevelExtension on StressLevel {
  String title(Translations t) {
    switch (this) {
      case StressLevel.veryStressed:
        return t.workout_quiz.steps.stress_level.very_stressed;
      case StressLevel.stressed:
        return t.workout_quiz.steps.stress_level.stressed;
      case StressLevel.neutral:
        return t.workout_quiz.steps.stress_level.neutral;
      case StressLevel.calm:
        return t.workout_quiz.steps.stress_level.calm;
      case StressLevel.veryRelaxed:
        return t.workout_quiz.steps.stress_level.very_relaxed;
    }
  }
}
