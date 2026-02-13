import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/validators/name_validator.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('NameValidator.validate', () {
    test('returns nameRequired for null', () {
      expect(NameValidator.validate(null), t.validation.nameRequired);
    });

    test('returns nameRequired for empty string', () {
      expect(NameValidator.validate(''), t.validation.nameRequired);
    });

    test('returns nameRequired for whitespace-only string', () {
      expect(NameValidator.validate('   '), t.validation.nameRequired);
    });

    test('returns nameMinLength for single character', () {
      expect(NameValidator.validate('A'), t.validation.nameMinLength);
    });

    test('returns nameMinLength for single char with spaces', () {
      expect(NameValidator.validate(' A '), t.validation.nameMinLength);
    });

    test('returns nameMaxLength for string over 100 characters', () {
      final longName = 'A' * 101;
      expect(NameValidator.validate(longName), t.validation.nameMaxLength);
    });

    test('returns nameInvalidCharacters for digits', () {
      expect(NameValidator.validate('John123'), t.validation.nameInvalidCharacters);
    });

    test('returns nameInvalidCharacters for special characters', () {
      expect(NameValidator.validate('John@Doe'), t.validation.nameInvalidCharacters);
    });

    test('returns null for valid name with letters', () {
      expect(NameValidator.validate('John'), isNull);
    });

    test('returns null for valid name with spaces', () {
      expect(NameValidator.validate('John Doe'), isNull);
    });

    test('returns null for valid name with hyphen', () {
      expect(NameValidator.validate('Mary-Jane'), isNull);
    });

    test('returns null for valid name with apostrophe', () {
      expect(NameValidator.validate("O'Brien"), isNull);
    });

    test('returns null for valid name with accented characters', () {
      expect(NameValidator.validate('José'), isNull);
    });

    test('returns null for exactly 2 characters', () {
      expect(NameValidator.validate('Jo'), isNull);
    });

    test('returns null for exactly 100 characters', () {
      final name = 'A' * 100;
      expect(NameValidator.validate(name), isNull);
    });
  });
}
