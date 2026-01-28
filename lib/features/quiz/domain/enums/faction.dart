import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum Faction {
  gakki,

  gyohyo,

  serien,
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
}
