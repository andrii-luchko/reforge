import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/settings/ui/page/settings_content/email_content.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

import '../../../helpers/test_setup.dart';

Widget _harness(
  GenericValidationCubit<String?> cubit, {
  void Function(String message)? onExternalError,
}) {
  Widget content = const Scaffold(
    body: CustomScrollView(
      slivers: [EmailContent(initialEmail: 'old@example.com')],
    ),
  );
  if (onExternalError != null) {
    content = GenericSaveListener<String?>(
      onError: onExternalError,
      child: content,
    );
  }

  final app = MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: BlocProvider.value(
      value: cubit,
      child: content,
    ),
  );

  return app;
}

void main() {
  setUpAll(initTestTranslations);

  testWidgets('disables unchanged and in-flight submissions', (tester) async {
    final completer = Completer<void>();
    final cubit = GenericValidationCubit<String?>(
      initialValue: 'old@example.com',
      validator: (_) => null,
      onSave: (_) => completer.future,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_harness(cubit));
    expect(tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed, isNull);

    cubit.onChanged('new@example.com');
    await tester.pump();
    expect(tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed, isNotNull);

    final save = cubit.save();
    await tester.pump();
    await tester.pump();
    expect(tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed, isNull);

    completer.complete();
    await save;
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('routes server errors to the save listener without marking the email field invalid', (tester) async {
    String? externalError;
    final cubit = GenericValidationCubit<String?>(
      initialValue: 'old@example.com',
      validator: (_) => null,
      onSave: (_) async => throw Exception('Network error'),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _harness(
        cubit,
        onExternalError: (message) => externalError = message,
      ),
    );
    cubit.onChanged('new@example.com');
    await cubit.save();
    await tester.pump();

    final field = tester.widget<AppTextField>(find.byType(AppTextField));
    expect(field.errorText, isNull);
    expect(externalError, contains('Network error'));
    expect(tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('does not render server errors next to the email field and allows retry', (tester) async {
    final cubit = GenericValidationCubit<String?>(
      initialValue: 'old@example.com',
      validator: (_) => null,
      onSave: (_) async => throw Exception('Email already in use'),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_harness(cubit));
    cubit.onChanged('used@example.com');
    await cubit.save();
    await tester.pump();

    final field = tester.widget<AppTextField>(find.byType(AppTextField));
    expect(field.errorText, isNull);
    expect(tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
