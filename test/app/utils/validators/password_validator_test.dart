import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/validators/password.dart';
import 'package:reforge/generated/i18n/strings.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('validatePassword', () {
    test('returns password_required for null', () {
      expect(validatePassword(null), t.validation.password_required);
    });

    test('returns password_required for empty string', () {
      expect(validatePassword(''), t.validation.password_required);
    });

    test('returns password_required for whitespace-only string', () {
      expect(validatePassword('   '), t.validation.password_required);
    });

    test('returns password_too_short for less than 8 characters', () {
      expect(validatePassword('short'), t.validation.password_too_short);
    });

    test('returns password_too_short for 7 characters', () {
      expect(validatePassword('1234567'), t.validation.password_too_short);
    });

    test('returns null for 8 characters', () {
      expect(validatePassword('12345678'), isNull);
    });

    test('returns null for longer password', () {
      expect(validatePassword('validpassword123'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('returns password_required for empty confirm password', () {
      expect(
        validateConfirmPassword('', 'password123'),
        t.validation.password_required,
      );
    });

    test('returns password_required for null confirm password', () {
      expect(
        validateConfirmPassword(null, 'password123'),
        t.validation.password_required,
      );
    });

    test('returns passwords_not_match when passwords differ', () {
      expect(
        validateConfirmPassword('password123', 'different'),
        t.validation.passwords_not_match,
      );
    });

    test('returns null when passwords match', () {
      expect(
        validateConfirmPassword('password123', 'password123'),
        isNull,
      );
    });

    test('returns null when passwords match with whitespace', () {
      expect(
        validateConfirmPassword('  password123  ', '  password123  '),
        isNull,
      );
    });
  });
}
