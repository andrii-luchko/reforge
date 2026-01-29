import 'package:reforge/generated/i18n/translations.g.dart';

enum LeaderboardMode {
  users,
  factions,
}

extension LeaderboardTypeX on LeaderboardMode {
  String title(Translations t) {
    switch (this) {
      case LeaderboardMode.users:
        return 'Leaderboard';
      case LeaderboardMode.factions:
        return 'Faction wars';
    }
  }
}
