import 'package:json_annotation/json_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum HydratedLevel {
  @JsonValue(1)
  dehydrated,
  @JsonValue(2)
  slightlyDehydrated,
  @JsonValue(3)
  okay,
  @JsonValue(4)
  hydrated,
  @JsonValue(5)
  wellHydrated,
}

extension HydratedLevelExtension on HydratedLevel {
  String title(Translations t) {
    switch (this) {
      case HydratedLevel.dehydrated:
        return t.workout_quiz.steps.hydrated_level.dehydrated;
      case HydratedLevel.slightlyDehydrated:
        return t.workout_quiz.steps.hydrated_level.slightly_dehydrated;
      case HydratedLevel.okay:
        return t.workout_quiz.steps.hydrated_level.okay;
      case HydratedLevel.hydrated:
        return t.workout_quiz.steps.hydrated_level.hydrated;
      case HydratedLevel.wellHydrated:
        return t.workout_quiz.steps.hydrated_level.well_hydrated;
    }
  }
}
