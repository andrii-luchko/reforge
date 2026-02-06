class ImmortalForgeEntity {
  const ImmortalForgeEntity({
    required this.userId,
    required this.email,

    required this.score,
    required this.rank,
    required this.title,
    this.avatarUrl,
  });

  final int userId;
  final String email;
  final String? avatarUrl;
  final int score;
  final int rank;
  final String title;
}
