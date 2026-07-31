import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';

bool canStartLeaderboardGuide({
  required LeaderboardMode mode,
  required ImmortalForgesState state,
  required int? userId,
}) {
  return mode == LeaderboardMode.users && userId != null && state.areAllFactionsLoaded && state.currentList.isNotEmpty;
}
