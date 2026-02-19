import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';

void main() {
  group('XpFormatter.compact', () {
    test('returns raw number for values under 1000', () {
      expect(XpFormatter.compact(0), '0 XP');
      expect(XpFormatter.compact(999), '999 XP');
      expect(XpFormatter.compact(100), '100 XP');
    });

    test('formats thousands with K suffix', () {
      expect(XpFormatter.compact(1000), '1 K XP');
      expect(XpFormatter.compact(1500), '1.5 K XP');
      expect(XpFormatter.compact(999999), '1000 K XP');
    });

    test('formats millions with M suffix', () {
      expect(XpFormatter.compact(1000000), '1 M XP');
      expect(XpFormatter.compact(2500000), '2.5 M XP');
      expect(XpFormatter.compact(999999999), '1000 M XP');
    });

    test('formats billions with B suffix', () {
      expect(XpFormatter.compact(1000000000), '1 B XP');
      expect(XpFormatter.compact(1500000000), '1.5 B XP');
    });

    test('handles negative numbers', () {
      expect(XpFormatter.compact(-500), '-500 XP');
      expect(XpFormatter.compact(-1500), '-1.5 K XP');
    });

    test('uses custom extSuffix', () {
      expect(XpFormatter.compact(100, extSuffix: 'pts'), '100 pts');
    });

    test('omits suffix when extSuffix is empty', () {
      expect(XpFormatter.compact(1000, extSuffix: ''), '1 K');
    });

    test('adds space before suffix when suffix starts with letter or digit', () {
      expect(XpFormatter.compact(100), '100 XP');
      // ignore: avoid_redundant_argument_values
      expect(XpFormatter.compact(100, extSuffix: 'XP'), '100 XP');
    });
  });

  group('XpFormatter.precise', () {
    test('formats 1000 with space separator', () {
      expect(XpFormatter.precise(1000), '1 000');
    });

    test('formats 1234567 with space separators', () {
      expect(XpFormatter.precise(1234567), '1 234 567');
    });

    test('returns small numbers unchanged', () {
      expect(XpFormatter.precise(99), '99');
      expect(XpFormatter.precise(999), '999');
    });
  });
}
