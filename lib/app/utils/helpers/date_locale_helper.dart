import 'package:intl/intl.dart';

class DateLocaleHelper {
  static String getSeparator(String locale) {
    final dateFormat = DateFormat.yMd(locale);

    final pattern = dateFormat.pattern!;

    return pattern
        .replaceAll(RegExp('[a-zA-Z]'), '')
        .split('')
        .firstWhere(
          (e) => e.trim().isNotEmpty,
          orElse: () => '.',
        );
  }

  static bool isDayFirst(String locale) {
    final dateFormat = DateFormat.yMd(locale);
    final pattern = dateFormat.pattern!;
    return pattern.indexOf('d') < pattern.indexOf('M');
  }

  static String getHintText(String locale) {
    final separator = getSeparator(locale);
    final dayFirst = isDayFirst(locale);

    return dayFirst ? 'DD${separator}MM${separator}YYYY' : 'MM${separator}DD${separator}YYYY';
  }

  static String formatDate(DateTime date, {required bool isDayFirst, required String separator}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return isDayFirst ? '$day$separator$month$separator$year' : '$month$separator$day$separator$year';
  }
}
