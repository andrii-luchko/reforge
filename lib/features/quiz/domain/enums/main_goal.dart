import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum MainGoal {
  buildStrength,
  improveEndurance,
  enhanceFlexibility,
}

extension FitnessGoalExtension on MainGoal {
  String title(Translations t) {
    switch (this) {
      case MainGoal.buildStrength:
        return t.quiz.steps.main_goal.build_strength.title;
      case MainGoal.improveEndurance:
        return t.quiz.steps.main_goal.improve_endurance.title;
      case MainGoal.enhanceFlexibility:
        return t.quiz.steps.main_goal.enhance_flexibility.title;
    }
  }

  String description(Translations t) {
    switch (this) {
      case MainGoal.buildStrength:
        return t.quiz.steps.main_goal.build_strength.description;
      case MainGoal.improveEndurance:
        return t.quiz.steps.main_goal.improve_endurance.description;
      case MainGoal.enhanceFlexibility:
        return t.quiz.steps.main_goal.enhance_flexibility.description;
    }
  }
}
