import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('validateEmail', () {
    test('returns email_required for null', () {
      expect(validateEmail(null), t.validation.email_required);
    });

    test('returns email_required for empty string', () {
      expect(validateEmail(''), t.validation.email_required);
    });

    test('returns email_required for whitespace-only string', () {
      expect(validateEmail('   '), t.validation.email_required);
    });

    test('returns email_invalid for string without @', () {
      expect(validateEmail('invalidemail'), t.validation.email_invalid);
    });

    test('returns email_invalid for string without domain', () {
      expect(validateEmail('user@'), t.validation.email_invalid);
    });

    test('returns email_invalid for invalid format', () {
      expect(validateEmail('user@domain'), t.validation.email_invalid);
    });

    test('returns null for valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('returns null for valid email with subdomain', () {
      expect(validateEmail('user@mail.example.com'), isNull);
    });

    test('returns null for valid email with hyphen', () {
      expect(validateEmail('user-name@example.co.uk'), isNull);
    });
  });
}
