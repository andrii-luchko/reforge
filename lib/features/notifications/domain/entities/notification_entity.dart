import 'package:intl/intl.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';

class NotificationEntity {
  NotificationEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
  });

  final int id;
  final String title;
  final String subtitle;
  final DateTime date;
  final NotificationType type;
}

extension DateTimeFormatting on DateTime {
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
