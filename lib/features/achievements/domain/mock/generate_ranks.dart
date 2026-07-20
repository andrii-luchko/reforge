import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/achievements/domain/enums/rank.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

class RanksGenerator {
  RanksGenerator._();

  static List<RankEntity> generateRanks(Faction faction) {
    const ranks = Rank.values;

    return List.generate(10, (i) {
      final level = 10 + (i * 7);
      final maxXp = 1000 + (i * 500);

      final currentXp = (maxXp * (0.2 + (i * 0.07))).toInt().clamp(0, maxXp);

      final rank = ranks[i % ranks.length];

      final imageAsset = rank.imageAsset(faction);

      return RankEntity(
        imageAsset: imageAsset,
        japanRankName: rank.japaneseName,
        rankName: rank.englishName,
        faction: faction,
        lvl: level,
        xp: currentXp,
        maxXp: maxXp,
      );
    });
  }
}
