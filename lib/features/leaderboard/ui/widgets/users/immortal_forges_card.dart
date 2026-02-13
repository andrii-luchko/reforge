// ignore_for_file: prefer_match_file_name
import 'package:flutter/material.dart';
// Ensure these imports are correct in your project structure
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/text_style_extension.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/domain/helpers/top_five_titles_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/gradient_line.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/leader_box.painter.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/rhombus_painter.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/gradient_text_header.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:skeletonizer/skeletonizer.dart';

const double designWidth = 358;
const double designHeight = 226;

class ImmortalForcesCardShimmer extends StatelessWidget {
  const ImmortalForcesCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: LeaderBoxClipper(),
      child: const Bone(
        width: designWidth,
        height: designHeight,
      ),
    );
  }
}

class ImmortalForcesCardEmpty extends StatelessWidget {
  const ImmortalForcesCardEmpty({
    required this.faction,
    super.key,
  });
  final Faction faction;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: designWidth / designHeight,
      child: Container(
        decoration: BoxDecoration(
          color: context.appTheme.beige900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appTheme.strokeCard),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon_outlined, size: 48, color: context.appTheme.beige100),
            const SizedBox(height: 12),
            Text(
              t.leaderboard.immortalForges.noLeaders(faction: faction.title(t)),
              style: subheadH5Medium.copyWith(
                color: context.appTheme.beige100,
              ),
              strutStyle: subheadH5Medium.strut,
            ),
            const SizedBox(height: 4),
            Text(
              t.leaderboard.immortalForges.beFirst,
              style: subheadH8Semibold.copyWith(color: context.appTheme.beige700),
            ),
          ],
        ),
      ),
    );
  }
}

class ImmortalForcesCard extends StatelessWidget {
  const ImmortalForcesCard({
    required this.users,
    super.key,
  });

  final List<ImmortalForgeEntity> users;

  ImmortalForgeEntity? _getUserByRank(int rank) {
    return users.where((u) => u.rank == rank).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final ranks = Iterable.generate(5, (i) => _getUserByRank(i + 1)).toList();
    final userRank1 = ranks.first;

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
                    Align(
                      alignment: const Alignment(0, -0.8),
                      child: GradientTextHeader(
                        immortalText: t.leaderboard.immortalForges.immortal,
                        forgesText: t.leaderboard.immortalForges.forges,
                      ),
                    ),

                    if (ranks[1] != null) const _RankLabel(rank: 2, alignment: Alignment(-0.9, -0.2)),
                    if (ranks[2] != null) const _RankLabel(rank: 3, alignment: Alignment(0.9, -0.2)),
                    if (ranks[4] != null) const _RankLabel(rank: 5, alignment: Alignment(0.9, 0.2)),
                    if (ranks[3] != null) const _RankLabel(rank: 4, alignment: Alignment(-0.9, 0.2)),

                    if (ranks.isNotEmpty)
                      const Center(
                        child: GradientLine(),
                      ),

                    if (userRank1 != null) ...[
                      Center(
                        child: LeaderBoardAvatar(
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
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 107, minHeight: 33, maxHeight: 33),
          child: CustomPaint(
            painter: RhombusPainter(
              strokeGradientColors: isMainLeader ? [const Color(0xFFD4AD38), const Color(0xFF5D4B17)] : null,
            ),
            child: Padding(
              padding: const .symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  topFiveTitlesByRank(rank),
                  style: subheadH5Medium.copyWith(
                    color: context.appTheme.beige100,
                    height: 1,
                  ),
                  strutStyle: subheadH5Medium.strut,
                  textAlign: .center,
                ),
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

  final ImmortalForgeEntity user;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: LeaderBoardAvatar(
        size: const Size(62, 62),
        imageUrl: user.avatarUrl,
        borderGradientColors: getGradientByRank(user.rank, context),
      ),
    );
  }
}
