import 'package:flutter/material.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';
import 'package:reforge/shared/empty_list_message.dart';

class SliverBadgesGrid extends StatelessWidget {
  const SliverBadgesGrid({required this.badges, super.key});

  final List<BadgeEntity> badges;
  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SliverEmptyListMessage(
        title: 'No Badges Found',
        subtitle: 'It looks like you have no badges yet.',
        icon: Icons.emoji_events_outlined,
      );
    }
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
          ).animateEntrance();
        },
        childCount: badges.length,
      ),
    );
  }
}
