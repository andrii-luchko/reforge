import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/week_day.dart';

void main() {
  group('WeekDay.fromValue', () {
    test('returns monday for 1', () {
      expect(WeekDay.fromValue(1), WeekDay.monday);
    });

    test('returns tuesday for 2', () {
      expect(WeekDay.fromValue(2), WeekDay.tuesday);
    });

    test('returns wednesday for 3', () {
      expect(WeekDay.fromValue(3), WeekDay.wednesday);
    });

    test('returns thursday for 4', () {
      expect(WeekDay.fromValue(4), WeekDay.thursday);
    });

    test('returns friday for 5', () {
      expect(WeekDay.fromValue(5), WeekDay.friday);
    });

    test('returns saturday for 6', () {
      expect(WeekDay.fromValue(6), WeekDay.saturday);
    });

    test('returns sunday for 7', () {
      expect(WeekDay.fromValue(7), WeekDay.sunday);
    });

    test('returns null for 0', () {
      expect(WeekDay.fromValue(0), isNull);
    });

    test('returns null for 8', () {
      expect(WeekDay.fromValue(8), isNull);
    });

    test('returns null for negative value', () {
      expect(WeekDay.fromValue(-1), isNull);
    });
  });

  group('WeekDayMapper.toIntList', () {
    test('converts list of WeekDay to int list', () {
      final weekDays = [WeekDay.monday, WeekDay.wednesday, WeekDay.friday];
      expect(weekDays.toIntList(), [1, 3, 5]);
    });

    test('converts full week to 1-7', () {
      final allDays = WeekDay.values;
      expect(allDays.toIntList(), [1, 2, 3, 4, 5, 6, 7]);
    });

    test('returns empty list for empty input', () {
      expect(<WeekDay>[].toIntList(), isEmpty);
    });
  });
}
