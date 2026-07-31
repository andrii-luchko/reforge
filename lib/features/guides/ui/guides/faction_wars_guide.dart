import 'package:flutter/material.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum FactionWarsGuideStep {
  intro,
  battleMode,
  scoring,
  victoryPoints,
  monthlyRewards,
}

class FactionWarsGuide {
  FactionWarsGuide()
    : _anchors = {
        for (final step in FactionWarsGuideStep.values) step: GlobalKey(debugLabel: 'faction-wars-guide-${step.name}'),
      };

  final Map<FactionWarsGuideStep, GlobalKey> _anchors;

  GlobalKey anchor(FactionWarsGuideStep step) => _anchors[step]!;

  GuideSession get session {
    return GuideSession(
      id: GuideId.factionWars,
      steps: [
        for (final step in FactionWarsGuideStep.values) GuideStep(anchor: anchor(step)),
      ],
    );
  }

  Widget tooltip(FactionWarsGuideStep step) {
    final guide = t.guides.factionWars;

    return switch (step) {
      FactionWarsGuideStep.intro => GuideTooltip(
        title: guide.introTitle,
        description: guide.introDescription,
      ),
      FactionWarsGuideStep.battleMode => GuideTooltip(
        title: guide.battleModeTitle,
        description: guide.battleModeDescription,
      ),
      FactionWarsGuideStep.scoring => GuideTooltip(
        title: guide.scoringTitle,
        description: guide.scoringDescription,
      ),
      FactionWarsGuideStep.victoryPoints => GuideTooltip(
        title: guide.victoryPointsTitle,
        description: guide.victoryPointsDescription,
      ),
      FactionWarsGuideStep.monthlyRewards => GuideTooltip(
        title: guide.monthlyRewardsTitle,
        description: guide.monthlyRewardsDescription,
      ),
    };
  }
}
