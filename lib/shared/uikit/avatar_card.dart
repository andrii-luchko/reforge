import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/home/ui/guide/home_page_guide_scope.dart';
import 'package:reforge/features/home/ui/widgets/faction_widget.dart';
import 'package:reforge/features/home/ui/widgets/lvl_widget.dart';
import 'package:reforge/features/home/ui/widgets/rank_card.dart';
import 'package:reforge/features/home/ui/widgets/xp_indicator.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/avatar_rank_card/avatar_card_clipper.dart';
import 'package:reforge/shared/uikit/avatar_rank_card/avatar_card_painter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AvatarRankCard extends StatelessWidget {
  const AvatarRankCard({
    required this.rank,
    super.key,
  });

  final RankEntity rank;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final guide = context.read<MainPageGuide?>();

    return _AvatarCardBase(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          final xp = rank.xp;
          final progress = rank.progress;
          final hasXP = xp != null && progress != null;
          final lvl = rank.lvl;

          return Stack(
            children: [
              Positioned.fill(
                child: _buildRankImage(appTheme),
              ),
              if (hasXP)
                Positioned(
                  top: h * 0.02,
                  right: w * 0.02,
                  child: XpIndicatorWidget(
                    height: h * 0.4,
                    xp: xp,
                    xpProgress: progress,
                  ),
                ),

              if (lvl != null)
                Positioned(
                  top: 0,
                  left: w * 0.08,
                  child: _guideTarget(
                    guide: guide,
                    step: MainPageGuideStep.levelAndLegacy,
                    targetBorderRadius: BorderRadius.circular(4),
                    child: LvlWidget(lvl: lvl),
                  ),
                ),

              Positioned(
                bottom: h * 0.25,
                left: w * 0.03,
                child: FactionWidget(faction: rank.faction.title(t)),
              ),

              Positioned(
                bottom: h * 0.02,
                left: w * 0.01,
                width: w * 0.93,

                child: _guideTarget(
                  guide: guide,
                  step: MainPageGuideStep.rankAscension,
                  targetPadding: const EdgeInsets.all(4).copyWith(right: 32),
                  targetBorderRadius: BorderRadius.circular(4),
                  child: RankCard(
                    japanRankName: rank.japanRankName,
                    rankName: rank.rankName,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _guideTarget({
    required MainPageGuide? guide,
    required MainPageGuideStep step,
    required Widget child,
    EdgeInsets targetPadding = const EdgeInsets.all(6),
    BorderRadius targetBorderRadius = const BorderRadius.all(
      Radius.circular(16),
    ),
  }) {
    if (guide == null) return child;

    return GuideTarget(
      anchor: guide.anchor(step),
      scope: homePageGuideScope,
      tooltip: guide.tooltip(step),
      targetPadding: targetPadding,
      targetBorderRadius: targetBorderRadius,
      child: child,
    );
  }

  Widget _buildRankImage(AppTheme appTheme) {
    final xp = rank.xp;
    final progress = rank.progress;
    final hasXP = xp != null && progress != null;

    if (hasXP) {
      return CustomPaint(
        painter: AvatarCardPainter(color: appTheme.beige100),
        child: ClipPath(
          clipper: AvatarClipper(),
          child: Image.asset(
            rank.imageAsset,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        rank.imageAsset,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AvatarCardShimmer extends StatelessWidget {
  const AvatarCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _AvatarCardBase(
      child: ClipPath(clipper: AvatarClipper(), child: const Bone()),
    );
  }
}

class _AvatarCardBase extends StatelessWidget {
  const _AvatarCardBase({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AspectRatio(
      aspectRatio: 358 / 484,
      child: FittedBox(
        child: Container(
          width: 350,
          height: 480,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.beige900,
            borderRadius: .circular(10),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: [
                  appTheme.beige100.withValues(alpha: 0.6),
                  appTheme.beige100.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          child: child,
        ),
      ),
    );
  }
}
