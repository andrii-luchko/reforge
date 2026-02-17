import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

extension RemoteNotificationMapper on RemoteNotification {
  NotificationEntity toNotificationEntity() {
    return NotificationEntity(
      id: Object.hashAll([title, body, DateTime.now().millisecondsSinceEpoch]),
      title: title ?? t.notifications.defaultTitle,
      subtitle: body ?? '',
      date: DateTime.now(),
      type: NotificationType.unknown,
    );
  }
}
