import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/ui/widgets/treadmill_speed_stepper.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  testWidgets('changes metric speed in 0.1 km/h steps', (tester) async {
    final changes = <double>[];
    await _pumpStepper(
      tester,
      speedKmH: 1,
      measureSystem: MeasurementSystem.metric,
      onChangedKmH: changes.add,
    );

    expect(find.text('Speed (km/h)'), findsOneWidget);
    expect(find.text('1.0'), findsOneWidget);

    await tester.tap(find.byKey(TreadmillSpeedStepper.incrementKey));
    await tester.pump();

    expect(find.text('1.1'), findsOneWidget);
    expect(changes, [closeTo(1.1, 0.0001)]);

    await _disposeStepper(tester);
  });

  testWidgets('displays mph and converts the edited value back to canonical km/h', (tester) async {
    final changes = <double>[];
    await _pumpStepper(
      tester,
      speedKmH: 1,
      measureSystem: MeasurementSystem.imperial,
      onChangedKmH: changes.add,
    );

    expect(find.text('Speed (mph)'), findsOneWidget);
    expect(find.text('0.6'), findsOneWidget);

    await tester.tap(find.byKey(TreadmillSpeedStepper.incrementKey));
    await tester.pump();

    expect(find.text('0.7'), findsOneWidget);
    expect(changes.single, closeTo(MeasureSystemValues.toKm(0.7), 0.0001));

    await _disposeStepper(tester);
  });

  testWidgets('does not allow decrementing to zero', (tester) async {
    final changes = <double>[];
    await _pumpStepper(
      tester,
      speedKmH: 0.1,
      measureSystem: MeasurementSystem.metric,
      onChangedKmH: changes.add,
    );

    await tester.tap(find.byKey(TreadmillSpeedStepper.decrementKey));
    await tester.pump();

    expect(find.text('0.1'), findsOneWidget);
    expect(changes, isEmpty);

    await _disposeStepper(tester);
  });

  testWidgets('long press repeats visually and throttles worker commands', (tester) async {
    final changes = <double>[];
    await _pumpStepper(
      tester,
      speedKmH: 5,
      measureSystem: MeasurementSystem.metric,
      onChangedKmH: changes.add,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(TreadmillSpeedStepper.incrementKey)),
    );
    await tester.pump(const Duration(milliseconds: 1100));
    await gesture.up();
    await tester.pump();

    final displayed = double.parse(
      tester.widget<Text>(find.byKey(TreadmillSpeedStepper.valueKey)).data!,
    );
    final visualSteps = ((displayed - 5) / 0.1).round();

    expect(visualSteps, greaterThan(2));
    expect(changes.length, lessThan(visualSteps));
    expect(changes.last, closeTo(displayed, 0.0001));

    await _disposeStepper(tester);
  });
}

Future<void> _pumpStepper(
  WidgetTester tester, {
  required double speedKmH,
  required MeasurementSystem measureSystem,
  required ValueChanged<double> onChangedKmH,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeDataValues.darkThemeData,
      home: Scaffold(
        body: Center(
          child: TreadmillSpeedStepper(
            speedKmH: speedKmH,
            measureSystem: measureSystem,
            onChangedKmH: onChangedKmH,
          ),
        ),
      ),
    ),
  );
}

Future<void> _disposeStepper(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}
