import 'package:flutter/material.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum PlateOfKeraguraGuideStep {
  intro,
  unlockedPlate,
  lockedPlate,
}

class PlateOfKeraguraGuide {
  PlateOfKeraguraGuide()
    : _anchors = {
        for (final step in PlateOfKeraguraGuideStep.values)
          step: GlobalKey(debugLabel: 'plate-of-keragura-guide-${step.name}'),
      };

  final Map<PlateOfKeraguraGuideStep, GlobalKey> _anchors;

  GlobalKey anchor(PlateOfKeraguraGuideStep step) => _anchors[step]!;

  GuideSession session({
    required bool includeUnlockedPlate,
    required bool includeLockedPlate,
  }) {
    return GuideSession(
      id: GuideId.plateOfKeragura,
      steps: [
        GuideStep(anchor: anchor(PlateOfKeraguraGuideStep.intro)),
        if (includeUnlockedPlate) GuideStep(anchor: anchor(PlateOfKeraguraGuideStep.unlockedPlate)),
        if (includeLockedPlate) GuideStep(anchor: anchor(PlateOfKeraguraGuideStep.lockedPlate)),
      ],
    );
  }

  Widget tooltip(PlateOfKeraguraGuideStep step) {
    final guide = t.guides.plateOfKeragura;

    return switch (step) {
      PlateOfKeraguraGuideStep.intro => GuideTooltip(
        title: guide.introTitle,
        description: guide.introDescription,
      ),
      PlateOfKeraguraGuideStep.unlockedPlate => GuideTooltip(
        title: guide.unlockedPlateTitle,
        description: guide.unlockedPlateDescription,
      ),
      PlateOfKeraguraGuideStep.lockedPlate => GuideTooltip(
        title: guide.lockedPlateTitle,
        description: guide.lockedPlateDescription,
      ),
    };
  }
}
