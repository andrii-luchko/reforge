import 'package:reforge/generated/i18n/translations.g.dart';

enum FactionShowType {
  list,
  victoryPoints,
}

extension FactionShowTypeX on FactionShowType {
  String title(Translations t) {
    switch (this) {
      case FactionShowType.list:
        return 'Faction list';
      case FactionShowType.victoryPoints:
        return 'Victory Points';
    }
  }
}
