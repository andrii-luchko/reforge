part of 'leaderboard_cubit.dart';

enum LeaderboardStatus { initial, loading, success, error }

@freezed
sealed class LeaderboardState with _$LeaderboardState {
  const LeaderboardState._();

  const factory LeaderboardState({
    @Default(LeaderboardStatus.initial) LeaderboardStatus status,
    @Default(LeaderboardMode.users) LeaderboardMode mode,
    @Default(Faction.gakki) Faction selectedFaction,

    @Default({}) Map<Faction, List<LeaderboardUserModel>> usersCache,

    LeaderboardUserModel? currentUser,
    int? currentUserIndex,
  }) = _LeaderboardState;

  List<LeaderboardUserModel> get currentUsersList => usersCache[selectedFaction] ?? [];
}
