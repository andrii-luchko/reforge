import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/rhombus_painter.dart';

class VictoryCard extends StatelessWidget {
  const VictoryCard({required this.faction, required this.mode, super.key});

  final LeaderboardFactionModel faction;
  final FactionMode mode;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        gradient: context.appTheme.styleCard,
        borderRadius: .circular(20),
        border: faction.rank == 1
            ? GradientBoxBorder(
                gradient: getGradientByRank(faction.rank, context),
              )
            : Border.all(color: context.appTheme.strokeCard),
      ),
      child: Column(
        spacing: 10,
        children: [
          LeaderBoardAvatar.asset(
            borderGradientColors: getGradientByRank(faction.rank, context),
            assetPath: faction.avatarAsset,
            size: const Size(56, 56),
          ),

          Text(faction.name, style: subheadH3Medium.copyWith(color: context.appTheme.beige100)),

          CustomPaint(
            painter: RhombusPainter(),
            child: SizedBox.fromSize(
              size: const Size(78, 33),
              child: Center(
                child: FittedBox(
                  fit: .cover,
                  child: Text(
                    faction.scoreByMode(mode).toString(),
                    style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
