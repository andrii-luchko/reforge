import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/quiz/ui/widgets/date_text_field.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

import '../../../helpers/test_setup.dart';

Widget _harness({
  required ValueChanged<DateTime?> onDateSelected,
  DateTime? initialDate,
  String? errorText,
}) {
  return MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: Scaffold(
      body: DateInputField(
        initialDate: initialDate,
        errorText: errorText,
        onDateSelected: onDateSelected,
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    initTestTranslations();
    await initializeDateFormatting('en');
  });

  testWidgets('formats digits and emits a date only when input is complete', (tester) async {
    final values = <DateTime?>[];
    await tester.pumpWidget(_harness(onDateSelected: values.add));

    await tester.enterText(find.byType(TextFormField), '0222200');
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, '02/22/200');
    expect(values, [null]);

    await tester.enterText(find.byType(TextFormField), '02222002');
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, '02/22/2002');
    expect(values, [null, DateTime(2002, 2, 22)]);
  });

  testWidgets('does not replace an active draft after a parent rebuild', (tester) async {
    DateTime? selectedDate = DateTime(2002, 2, 22);
    await tester.pumpWidget(
      _harness(
        initialDate: selectedDate,
        onDateSelected: (date) => selectedDate = date,
      ),
    );

    await tester.enterText(find.byType(TextFormField), '02');
    expect(selectedDate, isNull);

    await tester.pumpWidget(
      _harness(
        initialDate: selectedDate,
        errorText: t.validation.date_of_birth_required,
        onDateSelected: (date) => selectedDate = date,
      ),
    );

    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, '02');
  });

  testWidgets('keeps the cursor at the edited date segment', (tester) async {
    await tester.pumpWidget(
      _harness(
        initialDate: DateTime(2002, 2, 22),
        onDateSelected: (_) {},
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '02/29/2002',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    await tester.pump();

    final controller = tester.widget<TextFormField>(find.byType(TextFormField)).controller!;
    expect(controller.text, '02/29/2002');
    expect(controller.selection.baseOffset, 5);
  });

  testWidgets('shows an input error for an impossible calendar date', (tester) async {
    await tester.pumpWidget(_harness(onDateSelected: (_) {}));

    await tester.enterText(find.byType(TextFormField), '02312002');
    await tester.pump();

    expect(tester.widget<AppTextField>(find.byType(AppTextField)).errorText, t.validation.date_of_birth_invalid);
  });
}
