import 'package:reforge/generated/i18n/translations.g.dart';

enum ForgeAttribute { kobo, kozuchi, sensho, kobokai, kannuki }

extension ForgeAttributeX on ForgeAttribute {
  String title(Translations t) {
    return switch (this) {
      ForgeAttribute.kobo => 'Kōbō',
      ForgeAttribute.kozuchi => 'Kozuchi',
      ForgeAttribute.sensho => 'Sensho',
      ForgeAttribute.kobokai => 'Kobokai',
      ForgeAttribute.kannuki => 'Kannuki',
    };
  }

  String subtitle(Translations t) {
    switch (this) {
      case ForgeAttribute.kobo:
        return 'The Soul Furnace';
      case ForgeAttribute.kozuchi:
        return 'The Craftsman’s Hammer';
      case ForgeAttribute.sensho:
        return 'The Stroke of War';
      case ForgeAttribute.kobokai:
        return 'The Workshop Unleashed';
      case ForgeAttribute.kannuki:
        return 'The Soul-Forge Gate-Locks';
    }
  }

  String description(Translations t) {
    switch (this) {
      case ForgeAttribute.kobo:
        return 'Measures growth and intensity.\nXP is awarded for personal records (PRs) and exceeding previous bests.';
      case ForgeAttribute.kozuchi:
        return 'Measures consistency and volume.\nXP increases through total workout completion and tonnage.';
      case ForgeAttribute.sensho:
        return 'Measures efficiency relative to potential.\nXP scales based on how close performance is to the target goal.';
      case ForgeAttribute.kobokai:
        return 'Measures cumulative lifetime effort.\nAwards XP for hitting large milestones (e.g., 100k kg lifted).';
      case ForgeAttribute.kannuki:
        return 'Measures streaks and discipline.\nLonger unbroken streaks act as a multiplier for all XP gains.';
    }
  }
}
