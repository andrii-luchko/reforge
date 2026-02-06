part of 'factions_leaderboard_cubit.dart';

@freezed
sealed class FactionsLeaderboardState with _$FactionsLeaderboardState {
  const FactionsLeaderboardState._();

  const factory FactionsLeaderboardState({
    @Default(FactionShowType.list) FactionShowType selectedType,

    @Default(FactionMode.currentFight) FactionMode selectedMode,

    @Default([]) List<LeaderboardFactionModel> factions,
    Faction? userFaction,
    @Default(false) bool isLoading,
    String? error,
  }) = _FactionsLeaderboardState;

  ({LeaderboardFactionModel myFaction, LeaderboardFactionModel opponent})? get versusMatchup {
    final sorted = factionsSortByMode;

    if (sorted.isEmpty || userFaction == null) return null;

    final userRankIndex = sorted.indexWhere((e) => e.faction == userFaction);

    if (userRankIndex == -1) return null;

    final myFactionModel = sorted[userRankIndex];
    LeaderboardFactionModel opponentModel;

    if (userRankIndex == 0) {
      opponentModel = sorted.length > 1 ? sorted[1] : sorted.first;
    } else {
      opponentModel = sorted.first;
    }

    return (myFaction: myFactionModel, opponent: opponentModel);
  }

  List<LeaderboardFactionModel> get factionsSortByMode {
    if (factions.isEmpty) return [];

    return [...factions]..sort((a, b) {
      final scoreA = a.scoreByMode(selectedMode);
      final scoreB = b.scoreByMode(selectedMode);
      final scoreCompare = scoreB.compareTo(scoreA);

      if (scoreCompare != 0) {
        return scoreCompare;
      }

      return a.name.compareTo(b.name);
    });
  }
}
