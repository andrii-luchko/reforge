import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/victory_card.dart';

class VictoryPointSection extends StatelessWidget {
  const VictoryPointSection({required this.factions, required this.mode, super.key});

  final List<LeaderboardFactionModel> factions;
  final FactionMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 12,
      children: [
        for (int i = 0; i < factions.length; i++) ...[
          VictoryCard(
            faction: factions[i],
            mode: mode,
          ),

          if (i != factions.length - 1)
            Text(
              ':',
              style: subheadH1Medium.copyWith(
                color: context.appTheme.beige700,
                height: 1,
              ),
            ),
        ],
      ],
    );
  }
}
