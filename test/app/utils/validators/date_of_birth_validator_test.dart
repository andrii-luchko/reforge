import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/validators/date_of_birth.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('validateDateOfBirth', () {
    final referenceDate = DateTime(2024, 6, 15);

    test('returns date_of_birth_required for null', () {
      expect(
        validateDateOfBirth(null, currentTime: referenceDate),
        t.validation.date_of_birth_required,
      );
    });

    test('returns date_of_birth_future for future date', () {
      final futureDob = DateTime(2025, 1, 1);
      expect(
        validateDateOfBirth(futureDob, currentTime: referenceDate),
        t.validation.date_of_birth_future,
      );
    });

    test('returns date_of_birth_too_young when DOB is today (age 0)', () {
      final todayDob = DateTime(2024, 6, 15);
      expect(
        validateDateOfBirth(todayDob, currentTime: referenceDate, minAge: 10),
        t.validation.date_of_birth_too_young(mimAge: 10),
      );
    });

    test('returns date_of_birth_invalid for age over 100', () {
      final oldDob = DateTime(1920, 1, 1);
      expect(
        validateDateOfBirth(oldDob, currentTime: referenceDate),
        t.validation.date_of_birth_invalid,
      );
    });

    test('returns date_of_birth_too_young when age below minAge', () {
      final youngDob = DateTime(2020, 6, 15);
      expect(
        validateDateOfBirth(youngDob, currentTime: referenceDate, minAge: 10),
        t.validation.date_of_birth_too_young(mimAge: 10),
      );
    });

    test('returns null for valid date at exactly minAge', () {
      final dob = DateTime(2014, 6, 15);
      expect(
        validateDateOfBirth(dob, currentTime: referenceDate, minAge: 10),
        isNull,
      );
    });

    test('returns null for valid date above minAge', () {
      final dob = DateTime(1990, 3, 20);
      expect(
        validateDateOfBirth(dob, currentTime: referenceDate, minAge: 10),
        isNull,
      );
    });

    test('returns null for valid date at exactly 100 years old', () {
      final dob = DateTime(1924, 6, 15);
      expect(
        validateDateOfBirth(dob, currentTime: referenceDate),
        isNull,
      );
    });

    test('uses custom minAge parameter', () {
      final dob = DateTime(2018, 6, 15);
      expect(
        validateDateOfBirth(dob, currentTime: referenceDate, minAge: 18),
        t.validation.date_of_birth_too_young(mimAge: 18),
      );
    });
  });
}
