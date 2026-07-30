import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  initTestTranslations();

  test('builds the full Forge Attributes session in approved order', () {
    final guide = ForgeAttributesGuide();
    final session = guide.session(
      availableAttributes: ForgeAttribute.values,
    );

    expect(session, isNotNull);
    expect(session!.id, GuideId.forgeAttributes);
    expect(
      session.steps.map((step) => step.anchor),
      ForgeAttributesGuideStep.values.map(guide.anchor),
    );
  });

  test('keeps canonical order for partial and duplicated attributes', () {
    final guide = ForgeAttributesGuide();
    final session = guide.session(
      availableAttributes: const [
        ForgeAttribute.kannuki,
        ForgeAttribute.kobo,
        ForgeAttribute.kannuki,
        ForgeAttribute.sensho,
      ],
    );

    expect(
      session!.steps.map((step) => step.anchor),
      [
        guide.anchor(ForgeAttributesGuideStep.intro),
        guide.anchor(ForgeAttributesGuideStep.kobo),
        guide.anchor(ForgeAttributesGuideStep.waza),
        guide.anchor(ForgeAttributesGuideStep.taga),
      ],
    );
  });

  test('does not build an intro-only session', () {
    final guide = ForgeAttributesGuide();

    expect(
      guide.session(availableAttributes: const []),
      isNull,
    );
  });

  test('keeps the permanent attribute descriptions aligned with guide copy', () {
    expect(
      [
        for (final attribute in forgeAttributesDisplayOrder) attribute.description(t),
      ],
      [
        t.guides.forgeAttributes.koboDescription,
        t.guides.forgeAttributes.kozuchiDescription,
        t.guides.forgeAttributes.wazaDescription,
        t.guides.forgeAttributes.shogenTandaDescription,
        t.guides.forgeAttributes.tagaDescription,
      ],
    );
    expect(
      t.achievements.forgeAttributes.kobokai.subtitle,
      'The Workshop Unleashed',
    );
    expect(
      t.achievements.forgeAttributes.kannuki.subtitle,
      'The Soul-Furnace Containers',
    );
  });
}
