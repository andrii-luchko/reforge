import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

enum Rank {
  choko,
  joko,
  renko,
  tenko,
  jo,
  daizosho;

  static Rank fromJapaneseString(String rank) {
    switch (rank.toLowerCase()) {
      case 'chōkō':
        return Rank.choko;
      case 'jokō':
        return Rank.joko;
      case 'renkō':
        return Rank.renko;
      case 'tenkō':
        return Rank.tenko;
      case 'jō':
        return Rank.jo;
      case 'daizōshō':
        return Rank.daizosho;
      default:
        return Rank.choko;
    }
  }
}

extension RankExtension on Rank {
  String get japaneseName {
    switch (this) {
      case Rank.choko:
        return 'Chōkō';
      case Rank.joko:
        return 'Jokō';
      case Rank.renko:
        return 'Renkō';
      case Rank.tenko:
        return 'Tenkō';
      case Rank.jo:
        return 'Jō';
      case Rank.daizosho:
        return 'Daizōshō';
    }
  }

  String get englishName {
    switch (this) {
      case Rank.choko:
        return 'The Unrefined';
      case Rank.joko:
        return 'Apprentice';
      case Rank.renko:
        return 'Tempered Artisan';
      case Rank.tenko:
        return 'Heavenly Craftsman';
      case Rank.jo:
        return 'Forgemaster';
      case Rank.daizosho:
        return 'Great Artificier';
    }
  }

  String imageAsset(Faction faction) {
    final factionAssets = switch (faction) {
      Faction.gakki => [
        Assets.images.png.hojoshi1,
        Assets.images.png.hojoshi2,
        Assets.images.png.hojoshi3,
        Assets.images.png.hojoshi4,
        Assets.images.png.hojoshi5,
        Assets.images.png.hojoshi6,
      ],
      Faction.gyohyo => [
        Assets.images.png.yukon1,
        Assets.images.png.yukon2,
        Assets.images.png.yukon3,
        Assets.images.png.yukon4,
        Assets.images.png.yukon5,
        Assets.images.png.yukon6,
      ],
      Faction.seiren => [
        Assets.images.png.nagisabe1,
        Assets.images.png.nagisabe2,
        Assets.images.png.nagisabe3,
        Assets.images.png.nagisabe4,
        Assets.images.png.nagisabe5,
        Assets.images.png.nagisabe6,
      ],
    };

    final index = switch (this) {
      Rank.choko => 0,
      Rank.joko => 1,
      Rank.renko => 2,
      Rank.tenko => 3,
      Rank.jo => 4,
      Rank.daizosho => 5,
    };

    return factionAssets[index].path;
  }
}
