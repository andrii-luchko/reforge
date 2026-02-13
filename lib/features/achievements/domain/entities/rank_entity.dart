// ignore_for_file: sort_constructors_first

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
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

  factory RankEntity.mock() {
    return RankEntity.mockWith(t);
  }

  factory RankEntity.mockWith(Translations translations) {
    return RankEntity(
      imageUrl: Assets.images.png.avatar.path,
      rankName: translations.tiers.intermediate,
      faction: Faction.gakki,
      lvl: 78,
      xp: 3900,
      maxXp: 6000,
    );
  }
}
