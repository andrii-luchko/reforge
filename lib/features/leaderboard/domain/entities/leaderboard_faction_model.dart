import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class LeaderboardFactionModel {
  const LeaderboardFactionModel({
    required this.rank,
    required this.faction,
    required this.xp,
    required this.activeUsers,
    required this.globalScore,
    required this.localScore,
  });

  final int rank;
  final Faction faction;
  final int activeUsers;

  final int xp;

  final int globalScore;
  final int localScore;

  String get name => faction.title(t);
  String get avatarAsset => faction.avatarAssent();

  int scoreByMode(FactionMode mode) {
    return mode == .current ? localScore : globalScore;
  }
}
