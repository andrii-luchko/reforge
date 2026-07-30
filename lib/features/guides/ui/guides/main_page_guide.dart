import 'package:flutter/material.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum MainPageGuideStep {
  characterEvolution,
  rankAscension,
  levelAndLegacy,
}

class MainPageGuide {
  MainPageGuide()
    : _anchors = {
        for (final step in MainPageGuideStep.values) step: GlobalKey(debugLabel: 'main-page-guide-${step.name}'),
      };

  final Map<MainPageGuideStep, GlobalKey> _anchors;

  GlobalKey anchor(MainPageGuideStep step) => _anchors[step]!;

  GuideSession get session {
    return GuideSession(
      id: GuideId.mainPage,
      steps: [
        for (final step in MainPageGuideStep.values) GuideStep(anchor: anchor(step)),
      ],
    );
  }

  Widget tooltip(MainPageGuideStep step) {
    final guide = t.guides.mainPage;

    return switch (step) {
      MainPageGuideStep.characterEvolution => GuideTooltip(
        title: guide.characterEvolutionTitle,
        description: guide.characterEvolutionDescription,
      ),
      MainPageGuideStep.rankAscension => GuideTooltip(
        title: guide.rankAscensionTitle,
        description: guide.rankAscensionDescription,
      ),
      MainPageGuideStep.levelAndLegacy => GuideTooltip(
        title: guide.levelAndLegacyTitle,
        description: guide.levelAndLegacyDescription,
      ),
    };
  }
}
