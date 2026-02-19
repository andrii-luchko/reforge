import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/features/leaderboard/ui/widgets/xp_tag.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/base_list_tile_container.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LeaderboardFactionList extends StatelessWidget {
  const LeaderboardFactionList({required this.factions, required this.mode, super.key});

  final List<LeaderboardFactionModel> factions;
  final FactionMode mode;

  @override
  Widget build(BuildContext context) {
    return factions.isEmpty
        ? SliverEmptyListMessage(
            title: t.leaderboard.factions.emptyTitle,
            subtitle: t.leaderboard.factions.emptySubtitle,
            icon: Icons.groups_3_outlined,
          )
        : SliverList.separated(
            itemCount: factions.length,
            itemBuilder: (context, index) {
              final faction = factions[index];

              final rank = index + 1;
              return Skeleton.leaf(
                child:
                    LeaderboardFactionListTile(
                      key: ValueKey(faction.name),
                      faction: faction,
                      rank: rank,
                    ).animateEntrance(
                      index: index,
                    ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 8,
            ),
          );
  }
}

class LeaderboardFactionListTile extends StatelessWidget {
  const LeaderboardFactionListTile({required this.faction, required this.rank, super.key});

  final LeaderboardFactionModel faction;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          gradient: getGradientByRank(rank, context),
        ),
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
      ),
      child: BaseListTileContainer(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: 50,
                  child: Text(
                    rank.toString(),
                    style: subheadH3Medium.copyWith(color: appTheme.beige100),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LeaderBoardAvatar(
                borderGradientColors: getGradientByRank(rank, context),
                imageUrl: faction.avatarAsset,
                gradientWidth: 1.5,
                secondBorderWidth: 0,
                size: const Size(52, 52),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    faction.name,
                    style: subheadH3Medium.copyWith(color: appTheme.beige100),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    strutStyle: StrutStyle.fromTextStyle(
                      subheadH3Medium,
                      forceStrutHeight: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  XpTag(
                    xp: faction.xp,
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      t.leaderboard.factions.activeUsers,
                      style: subheadH8Semibold.copyWith(color: appTheme.beige700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      faction.activeUsers.toString(),
                      style: subheadH5Medium.copyWith(color: appTheme.beige100),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
