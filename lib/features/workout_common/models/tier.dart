import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:reforge/generated/i18n/translations.g.dart';

part 'tier.freezed.dart';

part 'tier.g.dart';

@freezed
sealed class Tier with _$Tier {
  const Tier._();

  const factory Tier({
    required String title,
    required String description,
    required int rank,
  }) = _Tier;

  factory Tier.fromJson(Map<String, dynamic> json) => _$TierFromJson(json);
}

List<Tier> get mockTiers => [
      Tier(
        title: t.workout_tiers.beginner,
        description: t.workout_tiers.beginnerDescription,
        rank: 1,
      ),
      Tier(
        title: t.workout_tiers.novice,
        description: t.workout_tiers.noviceDescription,
        rank: 2,
      ),
      Tier(
        title: t.workout_tiers.intermediate,
        description: t.workout_tiers.intermediateDescription,
        rank: 3,
      ),
      Tier(
        title: t.workout_tiers.advanced,
        description: t.workout_tiers.advancedDescription,
        rank: 4,
      ),
      Tier(
        title: t.workout_tiers.elite,
        description: t.workout_tiers.eliteDescription,
        rank: 5,
      ),
      Tier(
        title: t.workout_tiers.factionLeader,
        description: t.workout_tiers.factionLeaderDescription,
        rank: 6,
      ),
    ];
