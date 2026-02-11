class BadgeEntity {
  BadgeEntity({
    required this.imageUrl,
    required this.title,
    required this.isLocked,
  });

  final String imageUrl;
  final String title;
  final bool isLocked;
}
