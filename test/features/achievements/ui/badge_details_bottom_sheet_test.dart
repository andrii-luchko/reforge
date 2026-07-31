import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

Widget _harness(BadgeEntity badge) {
  return MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 120,
          child: BadgeCard(badge: badge),
        ),
      ),
    ),
  );
}

void main() {
  initTestTranslations();

  testWidgets('opens locked Tier 1 details from a badge card', (tester) async {
    const description = 'Measures the heaviest weight you can lift for one repetition in the back squat.';
    const badge = BadgeEntity(
      imageUrl: '',
      title: 'Warden',
      isLocked: true,
      requirementTitle: 'Squat 1RM',
      description: description,
    );

    await tester.pumpWidget(_harness(badge));
    await tester.tap(find.text('Warden'));
    await tester.pumpAndSettle();

    expect(find.text('Warden'), findsNWidgets(2));
    expect(find.text('Squat 1RM'), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(
      find.text(t.achievements.badgeDetails.lockedPreview),
      findsOneWidget,
    );
  });

  testWidgets('shows the current tier for an unlocked badge', (tester) async {
    const badge = BadgeEntity(
      imageUrl: '',
      title: 'Daystar Scout',
      isLocked: false,
      requirementTitle: 'Fastest 5 Mile',
      description: 'Tracks your fastest recorded time for a five-mile run.',
      tier: 4,
    );

    await tester.pumpWidget(_harness(badge));
    await tester.tap(find.text('Daystar Scout'));
    await tester.pumpAndSettle();

    expect(
      find.text(t.achievements.badgeDetails.currentTier(tier: 4)),
      findsOneWidget,
    );
  });

  testWidgets('does not open details when badge interaction is disabled', (
    tester,
  ) async {
    const badge = BadgeEntity(
      imageUrl: '',
      title: 'Warden',
      isLocked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 120,
              child: BadgeCard(
                badge: badge,
                isInteractionEnabled: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Warden'));
    await tester.pumpAndSettle();

    expect(find.text('Warden'), findsOneWidget);
  });
}
