import 'package:json_annotation/json_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum BodyFeel {
  @JsonValue(1)
  verySore,
  @JsonValue(2)
  sore,
  @JsonValue(3)
  slightlySore,
  @JsonValue(4)
  mostlyFresh,
  @JsonValue(5)
  fullyFresh,
}

extension BodyFeelExtension on BodyFeel {
  String title(Translations t) {
    switch (this) {
      case BodyFeel.verySore:
        return t.workout_quiz.steps.body_feel.very_sore;
      case BodyFeel.sore:
        return t.workout_quiz.steps.body_feel.sore;
      case BodyFeel.slightlySore:
        return t.workout_quiz.steps.body_feel.slightly_sore;
      case BodyFeel.mostlyFresh:
        return t.workout_quiz.steps.body_feel.mostly_fresh;
      case BodyFeel.fullyFresh:
        return t.workout_quiz.steps.body_feel.fully_fresh;
    }
  }
}
