import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

OnboardedUser createTestUser({
  String? userName,
  String? email,
  String? avatarUrl,
  double? bodyWeight,
  MeasurementSystem measurementSystem = MeasurementSystem.metric,
  DateTime? birthDate,
}) {
  return User.onboarded(
        id: 1,
        email: email ?? 'test@example.com',
        bodyWeight: bodyWeight,
        measurementSystem: measurementSystem,
        factionId: 1,
        secondaryFactionId: 2,
        birthDate: birthDate ?? DateTime(1990, 1, 15),
        workoutsPerWeek: 3,
        userName: userName,
        avatarUrl: avatarUrl,
      )
      as OnboardedUser;
}

void main() {
  setUpAll(() async {
    initTestTranslations();
    await initializeDateFormatting('en');
    await initializeDateFormatting('en_US');
  });

  group('ProfileSettingsX.getDisplayValue', () {
    test('image returns avatarUrl', () {
      final user = createTestUser(avatarUrl: 'https://example.com/avatar.png');
      expect(
        ProfileSettings.image.getDisplayValue(user, t),
        'https://example.com/avatar.png',
      );
    });

    test('image returns null when avatarUrl is null', () {
      final user = createTestUser();
      expect(ProfileSettings.image.getDisplayValue(user, t), isNull);
    });

    test('name returns userName when set', () {
      final user = createTestUser(userName: 'John');
      expect(ProfileSettings.name.getDisplayValue(user, t), 'John');
    });

    test('name returns setYourName when userName is null', () {
      final user = createTestUser();
      expect(
        ProfileSettings.name.getDisplayValue(user, t),
        t.settings.setYourName,
      );
    });

    test('email returns user email', () {
      final user = createTestUser(email: 'user@test.com');
      expect(ProfileSettings.email.getDisplayValue(user, t), 'user@test.com');
    });

    test('dateOfBirth returns formatted date', () {
      final user = createTestUser(birthDate: DateTime(1990, 3, 5));
      final result = ProfileSettings.dateOfBirth.getDisplayValue(user, t);
      expect(result, isNotNull);
      expect(result, contains('1990'));
      expect(result, contains('03'));
      expect(result, contains('05'));
    });

    test('heightAndWeight returns displayed weight with symbol when bodyWeight set', () {
      final user = createTestUser(bodyWeight: 70);
      final result = ProfileSettings.heightAndWeight.getDisplayValue(user, t);
      expect(result, '70 ${t.measure_system.weight.metric_symbol}');
    });

    test('heightAndWeight returns null when bodyWeight is null', () {
      final user = createTestUser();
      expect(ProfileSettings.heightAndWeight.getDisplayValue(user, t), isNull);
    });

    test('heightAndWeight converts to pounds for imperial', () {
      final user = createTestUser(
        bodyWeight: 1,
        measurementSystem: MeasurementSystem.imperial,
      );
      final result = ProfileSettings.heightAndWeight.getDisplayValue(user, t);
      expect(result, isNotNull);
      expect(result, contains(t.measure_system.weight.imperial_symbol));
    });

    test('heightAndWeight shows at most two decimal places', () {
      final user = createTestUser(bodyWeight: 70.555);
      final result = ProfileSettings.heightAndWeight.getDisplayValue(user, t);
      expect(result, '70.56 ${t.measure_system.weight.metric_symbol}');
    });
  });
}
