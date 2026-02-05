import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum Faction {
  gakki,
  gyohyo,
  serien
  ;

  static Faction? getById(int factionId) {
    switch (factionId) {
      case 1:
        return Faction.gakki;
      case 2:
        return Faction.serien;
      case 3:
        return Faction.gyohyo;

      default:
        return null;
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
      case Faction.serien:
        return t.common.factions.serien;
    }
  }

  String description(Translations t) {
    switch (this) {
      case Faction.gakki:
        return t.common.factions.gakki_description;
      case Faction.gyohyo:
        return t.common.factions.gyohyo_description;
      case Faction.serien:
        return t.common.factions.serien_description;
    }
  }

  String imageAssent() {
    switch (this) {
      case Faction.gakki:
        return Assets.images.png.factionGakki.path;
      case Faction.gyohyo:
        return Assets.images.png.factionGyohyo.path;
      case Faction.serien:
        return Assets.images.png.factionSerien.path;
    }
  }

  String avatarAssent() {
    switch (this) {
      case Faction.gakki:
        return Assets.images.png.factionGakki.path;
      case Faction.gyohyo:
        return Assets.images.png.factionGyohyo.path;
      case Faction.serien:
        return Assets.images.png.factionSerien.path;
    }
  }
}
