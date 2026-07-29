import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/ui/page/settings_content/height_and_weight_content.dart';

import '../../../core/user/mocks/mock_user_cubit.dart';
import '../../../helpers/test_setup.dart';

Widget _harness({
  required MeasurementSystem system,
  required ValueChanged<double?> onChanged,
  double? weightKg,
}) {
  return MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: Scaffold(
      body: WeightInputField(
        weightKg: weightKg,
        measurementSystem: system,
        onChanged: onChanged,
      ),
    ),
  );
}

String _fieldText(WidgetTester tester) {
  return tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text;
}

void main() {
  setUpAll(initTestTranslations);

  test('settings rounds canonical kilograms before saving', () async {
    final cubit = MockUserCubit();
    when(() => cubit.updateBodyWeight(any())).thenAnswer(
      (_) async => const Result.success(User.newUser(id: 1)),
    );

    await const HeightAndWeightPage(
      weight: null,
      system: MeasurementSystem.metric,
    ).onSave(70.555, cubit);

    verify(() => cubit.updateBodyWeight(70.56)).called(1);
  });

  testWidgets('shows metric kilograms rounded to two decimals', (tester) async {
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.metric,
        weightKg: 70.555,
        onChanged: (_) {},
      ),
    );

    expect(_fieldText(tester), '70.56');
    expect(find.text('kg'), findsOneWidget);
  });

  testWidgets('shows canonical kilograms as imperial pounds', (tester) async {
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.imperial,
        weightKg: 70,
        onChanged: (_) {},
      ),
    );

    expect(_fieldText(tester), '154.32');
    expect(find.text('lb'), findsOneWidget);
  });

  testWidgets('converts imperial input to canonical kilograms', (tester) async {
    double? emittedWeightKg;
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.imperial,
        onChanged: (value) => emittedWeightKg = value,
      ),
    );

    await tester.enterText(find.byType(TextFormField), '154.5');

    expect(emittedWeightKg, closeTo(70.080, 0.001));
  });

  testWidgets('normalizes comma and emits null when cleared', (tester) async {
    double? emittedWeightKg;
    var callbackCount = 0;
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.metric,
        onChanged: (value) {
          callbackCount++;
          emittedWeightKg = value;
        },
      ),
    );

    await tester.enterText(find.byType(TextFormField), '70,25');
    expect(_fieldText(tester), '70.25');
    expect(emittedWeightKg, 70.25);

    await tester.enterText(find.byType(TextFormField), '');
    expect(callbackCount, 2);
    expect(emittedWeightKg, isNull);
  });

  testWidgets('rejects a third decimal place and values above metric max', (tester) async {
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.metric,
        onChanged: (_) {},
      ),
    );

    await tester.enterText(find.byType(TextFormField), '70.12');
    await tester.enterText(find.byType(TextFormField), '70.123');
    expect(_fieldText(tester), '70.12');

    await tester.enterText(find.byType(TextFormField), '600');
    await tester.enterText(find.byType(TextFormField), '601');
    expect(_fieldText(tester), '600');
  });

  testWidgets('accepts four-digit imperial values with two decimals', (tester) async {
    await tester.pumpWidget(
      _harness(
        system: MeasurementSystem.imperial,
        onChanged: (_) {},
      ),
    );

    await tester.enterText(find.byType(TextFormField), '1324.99');
    expect(_fieldText(tester), '1324.99');

    await tester.enterText(find.byType(TextFormField), '1325');
    expect(_fieldText(tester), '1325');
  });

  testWidgets('reformats the same canonical value when system changes', (tester) async {
    final system = ValueNotifier(MeasurementSystem.metric);
    addTearDown(system.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: ValueListenableBuilder<MeasurementSystem>(
            valueListenable: system,
            builder: (context, value, _) {
              return WeightInputField(
                weightKg: 70,
                measurementSystem: value,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    );

    expect(_fieldText(tester), '70');
    system.value = MeasurementSystem.imperial;
    await tester.pump();
    expect(_fieldText(tester), '154.32');
  });
}
