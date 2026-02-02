import 'package:reforge/generated/i18n/translations.g.dart';

enum FactionMode {
  global,
  current,
}

extension FactionModeX on FactionMode {
  String title(Translations t) {
    switch (this) {
      case FactionMode.current:
        return 'Current fight';
      case FactionMode.global:
        return 'Global';
    }
  }
}
