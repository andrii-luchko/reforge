import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/router/app_router.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/notifications/data/mapper/remote_notification_mapper.dart';
import 'package:reforge/features/notifications/data/repository/notification_repository.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';
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
      final type = _tryParseData(message.data);
      final entity = notification.toNotificationEntity(type);
      toastification.showNotificationToast(entity, () {
        _handleNotificationNavigation(type);
      });
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification != null) {
      final type = _tryParseData(data);
      _handleNotificationNavigation(type);
    }
  }

  void _handleNotificationNavigation(NotificationType type) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case NotificationType.paymentFailed:
        unawaited(const SettingsSubscriptionPageRoute().push(context));

      case NotificationType.plateUnlocked:
      case NotificationType.weeklyWinner:
      case NotificationType.rankUpdate:
      case NotificationType.xpSummary:
      case NotificationType.unknown:
    }
  }

  NotificationType _tryParseData(Map<String, dynamic> data) {
    try {
      final notificationType = NotificationType.fromJson(data['type'].toString());
      logger.d('notificationType $notificationType');

      return notificationType;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger.d(e);
      return NotificationType.unknown;
    }
  }

  Future<void> sendTestNotification() async {
    await Future.delayed(const Duration(seconds: 1));
    await _repository.sendTestNotification();
  }

  Future<void> sendDefaultNotification() async {
    await _repository.sendDefaultTestNotification();
  }
}
