import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/extensions/string_extensions.dart';

void main() {
  group('StringExtensions.toCapitalized', () {
    test('returns empty string unchanged', () {
      expect(''.toCapitalized(), '');
    });

    test('capitalizes single character', () {
      expect('a'.toCapitalized(), 'A');
    });

    test('capitalizes lowercase string', () {
      expect('hello'.toCapitalized(), 'Hello');
    });

    test('leaves already capitalized string unchanged', () {
      expect('Hello'.toCapitalized(), 'Hello');
    });

    test('capitalizes first character only', () {
      expect('hello world'.toCapitalized(), 'Hello world');
    });
  });
}
