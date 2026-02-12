import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toDotString() {
    return DateFormat('dd.MM.yyyy').format(this);
  }

  String toDateTimeString() {
    return DateFormat('dd.MM.yyyy HH:mm').format(this);
  }

  String toShortDateString() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toNotificationTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(year, month, day);

    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(this);
    } else {
      final dayOfWeek = DateFormat('E').format(this).toLowerCase();
      final time = DateFormat('HH:mm').format(this);
      return '$dayOfWeek $time';
    }
  }
}
