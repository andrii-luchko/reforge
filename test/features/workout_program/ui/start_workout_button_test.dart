import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/start_workout_button.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  testWidgets('blocks repeated taps while workout start is pending', (tester) async {
    final start = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: StartWorkoutButton(
            onPressed: () {
              calls++;
              return start.future;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(StartWorkoutButton));
    await tester.pump();
    await tester.tap(find.byType(StartWorkoutButton));
    await tester.pump();

    expect(calls, 1);
    start.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
