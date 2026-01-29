import 'package:reforge/generated/i18n/translations.g.dart';

enum TierEnum {
  beginner,
  novice,
  intermediate,
  advanced,
  elite,
  factionLeader,
}

extension WorkoutMetricsX on TierEnum {
  String title(Translations t) {
    return switch (this) {
      TierEnum.beginner => t.tiers.beginner,
      TierEnum.novice => t.tiers.novice,
      TierEnum.intermediate => t.tiers.intermediate,
      TierEnum.advanced => t.tiers.advanced,
      TierEnum.elite => t.tiers.elite,
      TierEnum.factionLeader => t.tiers.factionLeader,
    };
  }
}
