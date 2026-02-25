// ignore_for_file: sort_constructors_first

import 'package:reforge/features/quiz/domain/enums/faction.dart';

import 'package:reforge/generated/i18n/translations.g.dart';

class RankEntity {
  RankEntity({
    required this.imageUrl,
    required this.rankName,
    required this.faction,
    required this.lvl,
    required this.xp,
    required this.maxXp,
  });

  final String imageUrl;
  final String rankName;
  final Faction faction;
  final int lvl;
  final int xp;
  final int maxXp;

  double get progress => (xp / maxXp).clamp(0, 1);

  factory RankEntity.mock([Faction? userFaction]) {
    return RankEntity.mockWith(t, userFaction);
  }

  factory RankEntity.mockWith(Translations translations, [Faction? userFaction]) {
    final faction = userFaction ?? Faction.gakki;
    return RankEntity(
      imageUrl: faction.rankCardAsset(),
      rankName: translations.tiers.intermediate,
      faction: faction,
      lvl: 1,
      xp: 10,
      maxXp: 200,
    );
  }
}
