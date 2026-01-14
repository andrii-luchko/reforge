import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum TrainingLevel {
  beginner,
  intermediate,
  advanced,
}

extension TrainingLevelExtension on TrainingLevel {
  String title(Translations translations) {
    switch (this) {
      case TrainingLevel.beginner:
        return translations.quiz.steps.training_level.beginner.title;
      case TrainingLevel.intermediate:
        return translations.quiz.steps.training_level.intermediate.title;
      case TrainingLevel.advanced:
        return translations.quiz.steps.training_level.advanced.title;
    }
  }

  String description(Translations translations) {
    switch (this) {
      case TrainingLevel.beginner:
        return translations.quiz.steps.training_level.beginner.description;
      case TrainingLevel.intermediate:
        return translations.quiz.steps.training_level.intermediate.description;
      case TrainingLevel.advanced:
        return translations.quiz.steps.training_level.advanced.description;
    }
  }
}
