import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/activity_section.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/badge_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeWorkoutResultSection extends StatelessWidget {
  const HomeWorkoutResultSection({
    required this.isLoading,
    required this.stats,
    super.key,
  });

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  final bool isLoading;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final badgeImage = stats.badgeImageUrl != null
        ? AppSvgListTileIcon.network(
            url: stats.badgeImageUrl!,
            color: context.appTheme.beige100,
            width: 56,
            height: 56,
            padding: .zero,
          )
        : AppSvgListTileIcon.asset(
            asset: Assets.images.icons.lock,
            color: context.appTheme.beige100,
          );

    return SliverSkeletonizer(
      enabled: isLoading,
      child: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: BadgeListTile(
                leadingIcon: badgeImage,
                title: stats.badgeName ?? context.t.home.badge.no_badge_yet,
                subtitle: context.t.home.badge.badge_earned,
              ),
            ),
          ),
          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: XpTile(
                currentXp: stats.currentXp,
                totalXp: stats.xpGoal,
              ),
            ),
          ),
          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ActivitySection(
                stats: stats,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
