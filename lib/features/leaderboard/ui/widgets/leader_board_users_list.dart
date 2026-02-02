import 'package:flutter/material.dart';

import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/shared/base_list_tile_container.dart';
import 'package:reforge/shared/uikit/app_tag.dart';

class LeaderBoardUsersList extends StatelessWidget {
  const LeaderBoardUsersList({required this.users, required this.currentUserIndex, super.key});

  final List<LeaderboardUserModel> users;
  final int? currentUserIndex;
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: users.length,
      itemBuilder: (context, index) {
        // final isMe = index == currentUserIndex;

        final user = users[index];
        return LeaderboardUserListTile(
          key: ValueKey(user.rank),
          user: user,
        ).animateEntrance();
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 8,
      ),
    );
  }
}

class LeaderboardUserListTile extends StatelessWidget {
  const LeaderboardUserListTile({required this.user, super.key});

  final LeaderboardUserModel user;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          gradient: getGradientByRank(user.rank, context),
        ),
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
      ),
      child: BaseListTileContainer(
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                user.rank.toString(),
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),
            ),
            const SizedBox(width: 8),
            LeaderBoardAvatar.network(
              borderGradientColors: getGradientByRank(user.rank, context),
              imageUrl: user.avatarUrl,
              gradientWidth: 1.5,
              secondBorderWidth: 0,
              size: const Size(48, 48),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                user.username,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            AppTag(
              text: 'XP:${XpFormatter.precise(user.xp)}',

              textStyle: subheadH8Semibold.copyWith(color: appTheme.beige100),
            ),
          ],
        ),
      ),
    );
  }
}
