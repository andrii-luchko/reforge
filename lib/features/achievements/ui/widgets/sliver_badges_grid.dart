import 'package:flutter/material.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/empty_list_message.dart';

class SliverBadgesGrid extends StatelessWidget {
  const SliverBadgesGrid({required this.badges, super.key});

  final List<BadgeEntity> badges;
  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return SliverEmptyListMessage(
        title: t.achievements.noBadgesFound,
        subtitle: t.achievements.noBadgesSubtitle,
        icon: Icons.emoji_events_outlined,
      );
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // childAspectRatio: 0.75,
        mainAxisExtent: 149,
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
