class BadgeEntity {
  const BadgeEntity({
    required this.imageUrl,
    required this.title,
    required this.isLocked,
    this.id,
    this.key,
    this.exerciseMetric,
    this.factionId,
    this.requirementTitle,
    this.description,
    this.tier,
  });

  final int? id;
  final String imageUrl;
  final String title;
  final bool isLocked;
  final String? key;
  final String? exerciseMetric;
  final int? factionId;
  final String? requirementTitle;
  final String? description;
  final int? tier;
}
