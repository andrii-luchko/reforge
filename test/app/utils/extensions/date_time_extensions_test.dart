import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';

void main() {
  group('DateTimeFormatting', () {
    final testDate = DateTime(2024, 3, 15, 14, 30);

    group('toDotString', () {
      test('formats date as dd.MM.yyyy', () {
        expect(testDate.toDotString(), '15.03.2024');
      });
    });

    group('toDateTimeString', () {
      test('formats date and time as dd.MM.yyyy HH:mm', () {
        expect(testDate.toDateTimeString(), '15.03.2024 14:30');
      });
    });

    group('toShortDateString', () {
      test('formats date as dd MMM yyyy', () {
        expect(testDate.toShortDateString(), '15 Mar 2024');
      });
    });

    group('toYearMonth', () {
      test('formats as yyyy-MM', () {
        expect(testDate.toYearMonth(), '2024-03');
      });
    });

    group('dateOnly', () {
      test('strips time component', () {
        final result = testDate.dateOnly;
        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });
    });

    group('toNotificationTime', () {
      test('returns HH:mm format for today', () {
        final now = DateTime.now();
        final todayWithTime = DateTime(now.year, now.month, now.day, 9, 45);
        expect(todayWithTime.toNotificationTime(), '09:45');
      });

      test('returns day of week and time for other day', () {
        final otherDay = DateTime(2020, 1, 15, 10, 30);
        final result = otherDay.toNotificationTime();
        expect(result, contains('10:30'));
        expect(result.length, greaterThan(5));
      });
    });
  });
}
