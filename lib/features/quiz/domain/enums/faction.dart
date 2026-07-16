import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum Faction {
  gakki,
  gyohyo,
  seiren;

  static Faction? fromId(int? factionId) {
    if (factionId == null) return null;

    switch (factionId) {
      case 1:
        return Faction.gakki;
      case 2:
        return Faction.seiren;
      case 3:
        return Faction.gyohyo;

      default:
        return null;
    }
  }

  int get id {
    switch (this) {
      case Faction.gakki:
        return 1;

      case Faction.seiren:
        return 2;
      case Faction.gyohyo:
        return 3;
    }
  }
}

extension FactionExtension on Faction {
  String title(Translations t) {
    switch (this) {
      case Faction.gakki:
        return t.common.factions.gakki;
      case Faction.gyohyo:
        return t.common.factions.gyohyo;
      case Faction.seiren:
        return t.common.factions.serien;
    }
  }

  String description(Translations t) {
    switch (this) {
      case Faction.gakki:
        return t.common.factions.gakki_description;
      case Faction.gyohyo:
        return t.common.factions.gyohyo_description;
      case Faction.seiren:
        return t.common.factions.serien_description;
    }
  }

  String imageAssent() {
    switch (this) {
      case Faction.gakki:
        return Assets.images.png.factionGakki.path;
      case Faction.gyohyo:
        return Assets.images.png.factionGyohyo.path;
      case Faction.seiren:
        return Assets.images.png.factionSeiren.path;
    }
  }

  String avatarAssent() {
    switch (this) {
      case Faction.gakki:
        return Assets.images.png.factionGakki.path;
      case Faction.gyohyo:
        return Assets.images.png.factionGyohyo.path;
      case Faction.seiren:
        return Assets.images.png.factionSeiren.path;
    }
  }

  String rankCardAsset(int level) {
    final factionAssets = switch (this) {
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

    final index = switch (level) {
      < 10 => 0,
      < 20 => 1,
      < 30 => 2,
      < 50 => 3,
      < 70 => 4,
      _ => 5,
    };

    return factionAssets[index].path;
  }
}
