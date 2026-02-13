import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/features/settings/ui/page/settings_content/workout_days_content.dart'
    show workoutFrequencyValidator;
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('workoutFrequencyValidator', () {
    test('returns select_days_count when count is null', () {
      final value = (daysPerWeek: null, specificDays: <WeekDay>[]);
      expect(
        workoutFrequencyValidator(value),
        t.validation.select_days_count,
      );
    });

    test('returns select_at_least_one_day when selectedDays is empty', () {
      final value = (daysPerWeek: 3, specificDays: <WeekDay>[]);
      expect(
        workoutFrequencyValidator(value),
        t.validation.select_at_least_one_day,
      );
    });

    test('returns not_enough_days_selected when selectedDays length < count', () {
      final value = (
        daysPerWeek: 3,
        specificDays: [WeekDay.monday, WeekDay.tuesday],
      );
      expect(
        workoutFrequencyValidator(value),
        t.validation.not_enough_days_selected(selected: 2, max: 3),
      );
    });

    test('returns too_many_days_selected when selectedDays length > count', () {
      final value = (
        daysPerWeek: 2,
        specificDays: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday],
      );
      expect(
        workoutFrequencyValidator(value),
        t.validation.too_many_days_selected(selected: 3, max: 2),
      );
    });

    test('returns null when valid', () {
      final value = (
        daysPerWeek: 2,
        specificDays: [WeekDay.monday, WeekDay.tuesday],
      );
      expect(workoutFrequencyValidator(value), isNull);
    });

    test('returns null when count equals selectedDays length', () {
      final value = (
        daysPerWeek: 3,
        specificDays: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday],
      );
      expect(workoutFrequencyValidator(value), isNull);
    });
  });
}
