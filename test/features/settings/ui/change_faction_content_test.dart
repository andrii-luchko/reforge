import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/settings/ui/page/settings_content/change_faction_content.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:toastification/toastification.dart';

import '../../../core/user/mocks/mock_user_cubit.dart';
import '../../../helpers/test_setup.dart';

final _user = OnboardedUser(
  id: 1,
  email: 'test@example.com',
  bodyWeight: 75,
  measurementSystem: MeasurementSystem.metric,
  factionId: Faction.gakki.id,
  secondaryFactionId: Faction.seiren.id,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
);

Widget _harness(UserCubit userCubit) {
  return ToastificationWrapper(
    child: MaterialApp(
      theme: ThemeDataValues.darkThemeData,
      home: BlocProvider<UserCubit>.value(
        value: userCubit,
        child: const ChangeFactionPage(
          initialFactions: [Faction.gakki, Faction.seiren],
        ),
      ),
    ),
  );
}

Finder _factionOption(Faction faction) {
  return find.ancestor(
    of: find.text(faction.title(t)),
    matching: find.byType(RadioButtonOption),
  );
}

void main() {
  setUpAll(initTestTranslations);

  testWidgets('shows one faction list with role tags and swaps selected roles', (tester) async {
    final userCubit = MockUserCubit();
    when(() => userCubit.state).thenReturn(UserState.loaded(_user));
    when(() => userCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_harness(userCubit));

    expect(find.text(t.settings.factionSelectionTitle), findsOneWidget);
    expect(find.byType(RadioButtonOption), findsNWidgets(Faction.values.length));
    expect(
      find.descendant(of: _factionOption(Faction.gakki), matching: find.text(t.settings.primaryFactionTag)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _factionOption(Faction.seiren), matching: find.text(t.settings.secondaryFactionTag)),
      findsOneWidget,
    );

    final secondary = _factionOption(Faction.seiren);
    await tester.ensureVisible(secondary);
    await tester.tap(secondary);
    await tester.pump();

    expect(
      find.descendant(of: _factionOption(Faction.seiren), matching: find.text(t.settings.primaryFactionTag)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _factionOption(Faction.gakki), matching: find.text(t.settings.secondaryFactionTag)),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('unselected faction replaces the secondary and it can be removed', (tester) async {
    final userCubit = MockUserCubit();
    when(() => userCubit.state).thenReturn(UserState.loaded(_user));
    when(() => userCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_harness(userCubit));

    final newSecondary = _factionOption(Faction.gyohyo);
    await tester.ensureVisible(newSecondary);
    await tester.tap(newSecondary);
    await tester.pump();

    expect(find.text(t.settings.secondaryFactionTag), findsOneWidget);
    expect(
      find.descendant(of: _factionOption(Faction.gyohyo), matching: find.text(t.settings.secondaryFactionTag)),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('remove-secondary-gyohyo')));
    await tester.pump();

    expect(find.text(t.settings.secondaryFactionTag), findsNothing);
    expect(tester.widget<RadioButtonOption>(_factionOption(Faction.gyohyo)).isSelected, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('saves selected roles as main and secondary faction IDs', (tester) async {
    final userCubit = MockUserCubit();
    when(() => userCubit.state).thenReturn(UserState.loaded(_user));
    when(() => userCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => userCubit.updateFactions(
        mainFaction: any(named: 'mainFaction'),
        secondFaction: any(named: 'secondFaction'),
      ),
    ).thenAnswer((_) async => Result.success(_user));

    await tester.pumpWidget(_harness(userCubit));

    final newPrimary = _factionOption(Faction.seiren);
    await tester.ensureVisible(newPrimary);
    await tester.tap(newPrimary);
    await tester.pump();

    final saveButton = find.byType(SecondaryButton);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    verify(
      () => userCubit.updateFactions(
        mainFaction: Faction.seiren.id,
        secondFaction: Faction.gakki.id,
      ),
    ).called(1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
