import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
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
        return '${t.quiz.steps.main_goal.build_strength.title} (${Faction.gakki.title(t)})';
      case MainGoal.improveEndurance:
        return '${t.quiz.steps.main_goal.improve_endurance.title} (${Faction.gyohyo.title(t)})';
      case MainGoal.enhanceFlexibility:
        return '${t.quiz.steps.main_goal.enhance_flexibility.title} (${Faction.seiren.title(t)})';
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

  Faction get faction {
    switch (this) {
      case MainGoal.buildStrength:
        return Faction.gakki;
      case MainGoal.improveEndurance:
        return Faction.gyohyo;
      case MainGoal.enhanceFlexibility:
        return Faction.seiren;
    }
  }
}
