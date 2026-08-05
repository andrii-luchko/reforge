import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/ui/widgets/running_mode_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  testWidgets('offers GPS and manual treadmill without exposing pedometer', (tester) async {
    RunningMode? selectedMode;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selectedMode = await RunningModeDialog.show(context);
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text(t.running.mode.outdoor_run), findsOneWidget);
    expect(find.text(t.running.mode.treadmill_run), findsOneWidget);
    expect(find.byKey(const ValueKey(RunningMode.gps)), findsOneWidget);
    expect(find.byKey(const ValueKey(RunningMode.treadmill)), findsOneWidget);
    expect(find.byKey(const ValueKey(RunningMode.pedometer)), findsNothing);

    await tester.tap(find.text(t.running.mode.treadmill_run));
    await tester.pumpAndSettle();

    expect(selectedMode, RunningMode.treadmill);
  });
}
