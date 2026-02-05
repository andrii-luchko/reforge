import 'package:reforge/generated/i18n/translations.g.dart';

enum FactionMode {
  global,
  currentFight,
}

extension FactionModeX on FactionMode {
  String title(Translations t) {
    switch (this) {
      case FactionMode.currentFight:
        return 'Current fight';
      case FactionMode.global:
        return 'Global';
    }
  }
}
