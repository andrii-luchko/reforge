import 'package:reforge/generated/i18n/translations.g.dart';

enum SleepQuality { veryPoor, poor, average, good, excellent }

extension SleepQualityExtension on SleepQuality {
  String title(Translations t) {
    switch (this) {
      case SleepQuality.veryPoor:
        return t.workout_quiz.steps.sleep_quality.very_poor;
      case SleepQuality.poor:
        return t.workout_quiz.steps.sleep_quality.poor;
      case SleepQuality.average:
        return t.workout_quiz.steps.sleep_quality.average;
      case SleepQuality.good:
        return t.workout_quiz.steps.sleep_quality.good;
      case SleepQuality.excellent:
        return t.workout_quiz.steps.sleep_quality.excellent;
    }
  }

  int get score {
    switch (this) {
      case SleepQuality.veryPoor:
        return 1;
      case SleepQuality.poor:
        return 2;
      case SleepQuality.average:
        return 3;
      case SleepQuality.good:
        return 4;
      case SleepQuality.excellent:
        return 5;
    }
  }
}
