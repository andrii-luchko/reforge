import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/extensions/int_extension.dart';

void main() {
  group('IntExtension.durationFormatted', () {
    test('returns 0 hours and 0 minutes for 0 seconds', () {
      final result = 0.durationFormatted;
      expect(result.hours, 0);
      expect(result.minutes, 0);
    });

    test('returns 0 hours and 1 minute for 90 seconds', () {
      final result = 90.durationFormatted;
      expect(result.hours, 0);
      expect(result.minutes, 1);
    });

    test('returns 1 hour and 1 minute for 3661 seconds', () {
      final result = 3661.durationFormatted;
      expect(result.hours, 1);
      expect(result.minutes, 1);
    });

    test('returns 2 hours and 30 minutes for 9000 seconds', () {
      final result = 9000.durationFormatted;
      expect(result.hours, 2);
      expect(result.minutes, 30);
    });
  });
}
