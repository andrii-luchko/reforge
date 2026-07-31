import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';

bool canStartFactionWarsGuide({
  required LeaderboardMode mode,
  required FactionsLeaderboardState state,
  required int? userId,
}) {
  return mode == LeaderboardMode.factions &&
      userId != null &&
      !state.isLoading &&
      state.error == null &&
      state.factions.isNotEmpty &&
      state.versusMatchup != null &&
      state.selectedType == FactionShowType.list;
}
