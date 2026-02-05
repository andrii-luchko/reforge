part of 'users_leaderboard_cubit.dart';

@freezed
sealed class UsersLeaderboardState with _$UsersLeaderboardState {
  const UsersLeaderboardState._();

  const factory UsersLeaderboardState({
    @Default(Faction.gakki) Faction selectedFaction,
    @Default([]) List<LeaderboardUserModel> currentUsersList,

    LeaderboardUserModel? currentUser,
    int? currentUserIndex,

    @Default(false) bool isLoading,
    @Default(false) bool isPaginationLoading,

    @Default(1) int currentPage,
    @Default(false) bool hasReachedMax,

    String? paginationError,
    String? error,
  }) = _UsersLeaderboardState;
}
