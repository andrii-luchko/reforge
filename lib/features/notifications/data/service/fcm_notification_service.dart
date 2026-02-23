import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/notifications/data/mapper/remote_notification_mapper.dart';
import 'package:reforge/features/notifications/data/models/notification_model_dto.dart';
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
      _tryParseData(message.data);
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    // TODO(reforge): Handle navigation when user taps notification (app was in background)

    final data = message.data;
    final notification = message.notification;
    if (notification != null) {
      _tryParseData(data);
      // Could navigate to notifications page, etc.
    }
  }

  void _tryParseData(Map<String, dynamic> data) {
    try {
      logger.d(NotificationModelDto.fromJson(data));
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger.d(e);
    }
  }

  Future<void> sendTestNotification() async {
    await Future.delayed(Duration(seconds: 1));
    await _repository.sendTestNotification();
  }

  Future<void> sendDefaultNotification() async {
    await _repository.sendDefaultTestNotification();
  }
}
