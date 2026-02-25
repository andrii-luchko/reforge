class LeaderboardUserEntity {
  const LeaderboardUserEntity({
    required this.rank,
    required this.username,
    required this.avatarUrl,
    required this.xp,
  });

  final int rank;
  final String username;
  final String? avatarUrl;
  final int xp;

  @override
  String toString() {
    return 'LeaderboardUserEntity(rank: $rank, username: $username, avatarUrl: $avatarUrl, xp: $xp)';
  }
}
