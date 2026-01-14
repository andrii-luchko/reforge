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
}
