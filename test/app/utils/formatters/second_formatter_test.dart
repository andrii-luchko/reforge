import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/formatters/second_formatter.dart';

void main() {
  group('formatSeconds', () {
    test('formats 0 as 00:00', () {
      expect(formatSeconds(0), '00:00');
    });

    test('formats 65 as 01:05', () {
      expect(formatSeconds(65), '01:05');
    });

    test('formats 3661 as 01:01:01', () {
      expect(formatSeconds(3661), '01:01:01');
    });

    test('formats 90 as 01:30', () {
      expect(formatSeconds(90), '01:30');
    });

    test('shows hours when alwaysShowHours is true', () {
      expect(formatSeconds(65, alwaysShowHours: true), '00:01:05');
    });

    test('shows hours for 0 when alwaysShowHours is true', () {
      expect(formatSeconds(0, alwaysShowHours: true), '00:00:00');
    });

    test('formats negative seconds as overtime with plus sign', () {
      expect(formatSeconds(-65), '+01:05');
    });

    test('formats negative 3661 as overtime with hours', () {
      expect(formatSeconds(-3661), '+01:01:01');
    });
  });
}
