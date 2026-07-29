// ignore_for_file: sort_constructors_first

import 'package:reforge/features/achievements/domain/enums/rank.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

import 'package:reforge/generated/i18n/translations.g.dart';

class RankEntity {
  RankEntity({
    required this.imageAsset,
    required this.japanRankName,
    required this.rankName,
    required this.faction,
    required this.lvl,
    required this.xp,
    required this.maxXp,
  });

  final String imageAsset;
  final String japanRankName;
  final String rankName;
  final Faction faction;
  final int? lvl;
  final int? xp;
  final int? maxXp;

  double? get progress {
    if (xp == null || maxXp == null || maxXp == 0) return null;

    return (xp! / maxXp!).clamp(0.0, 1.0);
  }

  factory RankEntity.mock([Faction? userFaction]) {
    return RankEntity.mockWith(t, userFaction);
  }

  factory RankEntity.mockWith(Translations t, [Faction? userFaction]) {
    final faction = userFaction ?? Faction.gakki;

    final rank = Rank.fromJapaneseString(t.home.default_japanese_rank_name);
    return RankEntity(
      imageAsset: rank.imageAsset(faction),
      japanRankName: t.home.default_japanese_rank_name,
      rankName: t.home.default_rank_name,
      faction: faction,
      lvl: 1,
      xp: 10,
      maxXp: 200,
    );
  }
}
