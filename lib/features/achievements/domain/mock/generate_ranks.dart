import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class RanksGenerator {
  RanksGenerator._();

  static List<RankEntity> generateRanks(Faction faction) {
    final names = <String>[
      t.tiers.beginner,
      t.tiers.intermediate,
      t.tiers.advanced,
      t.tiers.elite,
      t.tiers.factionLeader,
    ];

    return List.generate(10, (i) {
      final level = 10 + (i * 7);
      final maxXp = 1000 + (i * 500);

      final currentXp = (maxXp * (0.2 + (i * 0.07))).toInt().clamp(0, maxXp);

      return RankEntity(
        imageUrl: faction.rankCardAsset(),
        japanRankName: t.home.rank_label,
        rankName: names[i % names.length],
        faction: faction,
        lvl: level,
        xp: currentXp,
        maxXp: maxXp,
      );
    });
  }
}
