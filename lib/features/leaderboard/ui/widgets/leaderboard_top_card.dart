import 'package:flutter/material.dart';
// Ensure these imports are correct in your project structure
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/domain/helpers/top_five_titles_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/gradient_line.dart';
import 'package:reforge/features/leaderboard/ui/widgets/gradient_text_header.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/leader_box.painter.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/rhombus_painter.dart';

import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class ImmortalForcesCard extends StatelessWidget {
  const ImmortalForcesCard({
    required this.users,
    super.key,
  });

  final List<LeaderboardUserModel> users;

  LeaderboardUserModel? _getUserByRank(int rank) {
    return users.where((u) => u.rank == rank).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    const double designWidth = 358;
    const double designHeight = 226;

    final ranks = Iterable.generate(5, (i) => _getUserByRank(i + 1)).toList();
    final userRank1 = ranks[0];

    return AspectRatio(
      aspectRatio: designWidth / designHeight,
      child: FittedBox(
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: SunRaysShaderWidget.leaderBoard(
                  color: const Color.fromARGB(255, 245, 192, 0),
                ),
              ),
              CustomPaint(
                painter: LeaderBoxPainter(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Align(
                      alignment: Alignment(0, -0.8),
                      child: GradientTextHeader(),
                    ),

                    if (ranks[1] != null) const _RankLabel(rank: 2, alignment: Alignment(-0.9, -0.2)),
                    if (ranks[2] != null) const _RankLabel(rank: 3, alignment: Alignment(0.9, -0.2)),
                    if (ranks[4] != null) const _RankLabel(rank: 5, alignment: Alignment(0.9, 0.2)),
                    if (ranks[3] != null) const _RankLabel(rank: 4, alignment: Alignment(-0.9, 0.2)),

                    const Center(
                      child: GradientLine(),
                    ),

                    if (userRank1 != null) ...[
                      Center(
                        child: LeaderBoardAvatar.network(
                          size: const Size(88, 88),
                          borderGradientColors: getGradientByRank(1, context),
                          imageUrl: userRank1.avatarUrl,
                        ),
                      ),

                      const _RankLabel(
                        rank: 1,
                        alignment: Alignment(0, 0.8),
                        isMainLeader: true,
                      ),
                    ],

                    if (ranks[1] != null) _RankAvatar(user: ranks[1]!, alignment: const Alignment(-0.85, -0.9)),
                    if (ranks[2] != null) _RankAvatar(user: ranks[2]!, alignment: const Alignment(0.85, -0.9)),
                    if (ranks[3] != null) _RankAvatar(user: ranks[3]!, alignment: const Alignment(-0.85, 0.9)),
                    if (ranks[4] != null) _RankAvatar(user: ranks[4]!, alignment: const Alignment(0.85, 0.9)),
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

class _RankLabel extends StatelessWidget {
  const _RankLabel({
    required this.rank,
    required this.alignment,
    this.isMainLeader = false,
  });

  final int rank;
  final Alignment alignment;
  final bool isMainLeader;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox.fromSize(
        size: const Size(108, 32),
        child: CustomPaint(
          painter: RhombusPainter(
            strokeGradientColors: isMainLeader ? [const Color(0xFFD4AD38), const Color(0xFF5D4B17)] : null,
          ),
          child: Center(
            child: Text(
              topFiveTitlesByRank(rank),
              style: subheadH5Medium.copyWith(
                color: context.appTheme.beige100,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({
    required this.user,
    required this.alignment,
  });

  final LeaderboardUserModel user;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: LeaderBoardAvatar.network(
        size: const Size(64, 64),
        imageUrl: user.avatarUrl,
        borderGradientColors: getGradientByRank(user.rank, context),
      ),
    );
  }
}
