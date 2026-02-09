class LeaderboardUserModel {
  const LeaderboardUserModel({
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
    return 'LeaderboardUserModel(rank: $rank, username: $username, avatarUrl: $avatarUrl, xp: $xp)';
  }
}
