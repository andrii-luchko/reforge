import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  initTestTranslations();

  test('builds the fixed three-step session in approved order', () {
    final guide = MainPageGuide();

    expect(guide.session.id, GuideId.mainPage);
    expect(
      guide.session.steps.map((step) => step.anchor),
      [
        guide.anchor(MainPageGuideStep.characterEvolution),
        guide.anchor(MainPageGuideStep.rankAscension),
        guide.anchor(MainPageGuideStep.levelAndLegacy),
      ],
    );
  });

  test('uses the approved Main Page copy', () {
    final guide = MainPageGuide();

    expect(
      guide.tooltip(MainPageGuideStep.characterEvolution).toStringShort(),
      'GuideTooltip',
    );
    expect(t.guides.mainPage.characterEvolutionTitle, 'Character Evolution');
    expect(
      t.guides.mainPage.rankAscensionDescription,
      'Unlock all 10 badges in a tier to rank up and evolve your card.',
    );
    expect(
      t.guides.mainPage.levelAndLegacyDescription,
      'Levels raise your leaderboard position and unlock new Plates of Keragura.',
    );
  });
}
