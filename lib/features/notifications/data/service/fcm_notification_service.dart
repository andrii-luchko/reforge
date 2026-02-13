import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/notifications/data/mapper/remote_notification_mapper.dart';
import 'package:reforge/features/notifications/data/repository/notification_repository.dart';
import 'package:toastification/toastification.dart';

@singleton
class FcmNotificationService {
  FcmNotificationService(this._repository) {
    _setupListeners();
  }

  final NotificationRepository _repository;

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
  }

  void _onTokenRefresh(String token) {
    unawaited(_repository.saveFcmToken(token));
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final entity = notification.toNotificationEntity();
      toastification.showNotificationToast(entity);
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    // TODO(reforge): Handle navigation when user taps notification (app was in background)
    final notification = message.notification;
    if (notification != null) {
      // Could navigate to notifications page, etc.
    }
  }
}
