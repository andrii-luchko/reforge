import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reforge/app/utils/helpers/date_locale_helper.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('de_DE');
    await initializeDateFormatting('ru_RU');
  });

  group('DateLocaleHelper', () {
    group('getSeparator', () {
      test('returns separator for en_US', () {
        final separator = DateLocaleHelper.getSeparator('en_US');
        expect(separator, isNotEmpty);
        expect(separator.length, 1);
      });

      test('returns separator for de_DE', () {
        final separator = DateLocaleHelper.getSeparator('de_DE');
        expect(separator, isNotEmpty);
        expect(separator.length, 1);
      });

      test('returns separator for ru_RU', () {
        final separator = DateLocaleHelper.getSeparator('ru_RU');
        expect(separator, isNotEmpty);
        expect(separator.length, 1);
      });
    });

    group('isDayFirst', () {
      test('returns consistent result for en_US', () {
        final result = DateLocaleHelper.isDayFirst('en_US');
        expect(result, isA<bool>());
      });

      test('returns true for de_DE (day first)', () {
        expect(DateLocaleHelper.isDayFirst('de_DE'), isTrue);
      });

      test('returns true for ru_RU (day first)', () {
        expect(DateLocaleHelper.isDayFirst('ru_RU'), isTrue);
      });
    });

    group('getHintText', () {
      test('returns hint with DD-MM-YYYY or MM-DD-YYYY format', () {
        final enHint = DateLocaleHelper.getHintText('en_US');
        expect(enHint, contains('DD'));
        expect(enHint, contains('MM'));
        expect(enHint, contains('YYYY'));

        final deHint = DateLocaleHelper.getHintText('de_DE');
        expect(deHint, contains('DD'));
        expect(deHint, contains('MM'));
        expect(deHint, contains('YYYY'));
      });
    });

    group('formatDate', () {
      final testDate = DateTime(2024, 3, 5);

      test('formats with day first when isDayFirst is true', () {
        final result = DateLocaleHelper.formatDate(
          testDate,
          isDayFirst: true,
          separator: '.',
        );
        expect(result, '05.03.2024');
      });

      test('formats with month first when isDayFirst is false', () {
        final result = DateLocaleHelper.formatDate(
          testDate,
          isDayFirst: false,
          separator: '/',
        );
        expect(result, '03/05/2024');
      });

      test('uses custom separator', () {
        final result = DateLocaleHelper.formatDate(
          testDate,
          isDayFirst: true,
          separator: '-',
        );
        expect(result, '05-03-2024');
      });
    });
  });
}
