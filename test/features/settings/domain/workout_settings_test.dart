import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

OnboardedUser createTestUser({
  int factionId = 1,
  int? secondaryFactionId = 2,
  MeasurementSystem measurementSystem = MeasurementSystem.metric,
  int workoutsPerWeek = 3,
}) {
  return User.onboarded(
    id: 1,
    email: 'test@example.com',
    bodyWeight: 70,
    measurementSystem: measurementSystem,
    factionId: factionId,
    secondaryFactionId: secondaryFactionId,
    birthDate: DateTime(1990, 1, 15),
    workoutsPerWeek: workoutsPerWeek,
    userName: 'John',
  ) as OnboardedUser;
}

void main() {
  setUpAll(initTestTranslations);

  group('WorkoutSettingsX.getDisplayValue', () {
    test('subscription returns null', () {
      final user = createTestUser();
      expect(WorkoutSettings.subscription.getDisplayValue(user, t), isNull);
    });

    test('faction returns main and secondary faction titles', () {
      final user = createTestUser(factionId: 1, secondaryFactionId: 2);
      final result = WorkoutSettings.faction.getDisplayValue(user, t);
      expect(result, isNotNull);
      expect(result, contains(t.common.factions.gakki));
      expect(result, contains(t.common.factions.serien));
    });

    test('faction handles null secondaryFaction', () {
      final user = createTestUser(factionId: 1, secondaryFactionId: null);
      final result = WorkoutSettings.faction.getDisplayValue(user, t);
      expect(result, isNotNull);
      expect(result, contains(t.common.factions.gakki));
    });

    test('notification returns null', () {
      final user = createTestUser();
      expect(WorkoutSettings.notification.getDisplayValue(user, t), isNull);
    });

    test('measureSystem returns weight symbol for metric', () {
      final user = createTestUser(measurementSystem: MeasurementSystem.metric);
      final result = WorkoutSettings.measureSystem.getDisplayValue(user, t);
      expect(result, t.measure_system.weight.metric_symbol);
    });

    test('measureSystem returns weight symbol for imperial', () {
      final user = createTestUser(measurementSystem: MeasurementSystem.imperial);
      final result = WorkoutSettings.measureSystem.getDisplayValue(user, t);
      expect(result, t.measure_system.weight.imperial_symbol);
    });

    test('workoutDays returns daysPerWeek count', () {
      final user = createTestUser(workoutsPerWeek: 4);
      final result = WorkoutSettings.workoutDays.getDisplayValue(user, t);
      expect(result, t.settings.daysPerWeek(count: 4));
    });
  });
}
