import 'package:reforge/generated/i18n/translations.g.dart';

enum StressLevel {
  veryStressed,
  stressed,
  neutral,
  calm,
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
