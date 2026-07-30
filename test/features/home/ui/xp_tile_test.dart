import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  initTestTranslations();

  testWidgets('renders zero progress without dividing by zero', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: ThemeDataValues.darkThemeData,
          home: const Scaffold(
            body: XpTile(currentXp: 0, totalXp: 0),
          ),
        ),
      ),
    );

    expect(find.text('0%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
