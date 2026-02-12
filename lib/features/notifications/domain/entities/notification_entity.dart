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
