import 'package:flutter/cupertino.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';

class SliverBadgesGrid extends StatelessWidget {
  const SliverBadgesGrid({required this.badges, super.key});

  final List<BadgeEntity> badges;
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final badge = badges[index];

          return BadgeCard(
            badge: badge,
          );
        },
        childCount: badges.length,
      ),
    );
  }
}
