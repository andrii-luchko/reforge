import 'package:flutter/material.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum ForgeAttributesGuideStep {
  intro,
  kobo,
  kozuchi,
  waza,
  shogenTanda,
  taga,
  badges,
}

class ForgeAttributesGuide {
  ForgeAttributesGuide()
    : _anchors = {
        for (final step in ForgeAttributesGuideStep.values)
          step: GlobalKey(debugLabel: 'forge-attributes-guide-${step.name}'),
      };

  final Map<ForgeAttributesGuideStep, GlobalKey> _anchors;

  GlobalKey anchor(ForgeAttributesGuideStep step) => _anchors[step]!;

  GlobalKey attributeAnchor(ForgeAttribute attribute) {
    return anchor(stepForAttribute(attribute));
  }

  ForgeAttributesGuideStep stepForAttribute(ForgeAttribute attribute) {
    return switch (attribute) {
      ForgeAttribute.kobo => ForgeAttributesGuideStep.kobo,
      ForgeAttribute.kozuchi => ForgeAttributesGuideStep.kozuchi,
      ForgeAttribute.sensho => ForgeAttributesGuideStep.waza,
      ForgeAttribute.kobokai => ForgeAttributesGuideStep.shogenTanda,
      ForgeAttribute.kannuki => ForgeAttributesGuideStep.taga,
    };
  }

  GuideSession? session({
    required Iterable<ForgeAttribute> availableAttributes,
    bool includeBadges = false,
  }) {
    final available = availableAttributes.toSet();
    if (available.isEmpty) return null;

    return GuideSession(
      id: GuideId.forgeAttributes,
      steps: [
        GuideStep(anchor: anchor(ForgeAttributesGuideStep.intro)),
        for (final attribute in forgeAttributesDisplayOrder)
          if (available.contains(attribute))
            GuideStep(
              anchor: attributeAnchor(attribute),
            ),
        if (includeBadges)
          GuideStep(
            anchor: anchor(ForgeAttributesGuideStep.badges),
          ),
      ],
    );
  }

  Widget tooltip(ForgeAttributesGuideStep step) {
    final guide = t.guides.forgeAttributes;

    return switch (step) {
      ForgeAttributesGuideStep.intro => GuideTooltip(
        title: guide.introTitle,
        description: guide.introDescription,
      ),
      ForgeAttributesGuideStep.kobo => GuideTooltip(
        title: guide.koboTitle,
        description: guide.koboDescription,
      ),
      ForgeAttributesGuideStep.kozuchi => GuideTooltip(
        title: guide.kozuchiTitle,
        description: guide.kozuchiDescription,
      ),
      ForgeAttributesGuideStep.waza => GuideTooltip(
        title: guide.wazaTitle,
        description: guide.wazaDescription,
      ),
      ForgeAttributesGuideStep.shogenTanda => GuideTooltip(
        title: guide.shogenTandaTitle,
        description: guide.shogenTandaDescription,
      ),
      ForgeAttributesGuideStep.taga => GuideTooltip(
        title: guide.tagaTitle,
        description: guide.tagaDescription,
      ),
      ForgeAttributesGuideStep.badges => GuideTooltip(
        title: guide.badgesTitle,
        description: guide.badgesDescription,
      ),
    };
  }
}
