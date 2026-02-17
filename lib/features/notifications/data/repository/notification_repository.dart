import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/notifications/data/datasources/fcm_token_storage.dart';
import 'package:reforge/features/notifications/data/models/notification_test_request.dart';
import 'package:reforge/features/notifications/data/models/register_tokens_request.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/enum/device_type.dart';
import 'package:reforge/features/notifications/domain/enum/notification_permission_status.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';

typedef PaginatedNotifications = ({List<NotificationEntity> items, bool hasMore});

abstract interface class NotificationRepository {
  Future<Result<PaginatedNotifications>> getNotifications({
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> markNotificationAsRead(int id);
  Future<Result<void>> markAllAsRead();
  Future<Result<bool>> requestNotificationPermission();
  Future<Result<NotificationPermissionStatus>> getNotificationPermissionStatus();
  Future<Result<String?>> getFcmToken();
  Future<Result<void>> saveFcmToken(String token);
  Future<void> clearSavedFcmToken();
  Future<void> sendTestNotification(String token);
}

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl with RepositoryErrorHandler implements NotificationRepository {
  NotificationRepositoryImpl(this._firebaseMessaging, this._apiClient, this._fcmTokenStorage);

  final ApiClient _apiClient;
  final FirebaseMessaging _firebaseMessaging;
  final FcmTokenStorage _fcmTokenStorage;

  NotificationPermissionStatus _fromFirebase(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => NotificationPermissionStatus.authorized,
      AuthorizationStatus.denied => NotificationPermissionStatus.denied,
      AuthorizationStatus.notDetermined => NotificationPermissionStatus.notDetermined,
      AuthorizationStatus.provisional => NotificationPermissionStatus.provisional,
    };
  }

  @override
  Future<Result<bool>> requestNotificationPermission() async {
    try {
      final settings = await makeRequest(
        _firebaseMessaging.requestPermission,
        label: 'requestNotificationPermission',
      );
      return Result.success(
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional,
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<NotificationPermissionStatus>> getNotificationPermissionStatus() async {
    try {
      final settings = await makeRequest(
        _firebaseMessaging.getNotificationSettings,
        label: 'getNotificationPermissionStatus',
      );
      return Result.success(_fromFirebase(settings.authorizationStatus));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PaginatedNotifications>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final notifications = await makeRequest(
        () async {
          final response = await _apiClient.getNotificationHistory();
          final all = response.data.where((d) => !d.isRead).map((dto) => dto.toEntity()).toList();

          return (items: all, hasMore: false);
        },
        label: 'getNotifications',
      );

      return Result.success(notifications);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await makeRequest(
        _apiClient.markAllNotificationsAsRead,
        label: 'markAllAsRead',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> markNotificationAsRead(int id) async {
    try {
      await makeRequest(
        () {
          return _apiClient.markNotificationAsRead(id);
        },
        label: 'markNotificationAsRead',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<String?>> getFcmToken() async {
    try {
      final token = await makeRequest(
        _firebaseMessaging.getToken,
        label: 'getFcmToken',
      );
      logger.d('FCM token: $token');
      return Result.success(token);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> saveFcmToken(String token) async {
    try {
      final lastSaved = await _fcmTokenStorage.getLastSavedToken();
      if (token == lastSaved) {
        return const Result.success(null);
      }

      final result = await makeRequest(
        () => _apiClient.registerToken(
          RegisterFcmTokensRequestDto(
            token: token,
            deviceType: Platform.isAndroid ? DeviceType.android : DeviceType.ios,
          ),
        ),
        label: 'saveFcmToken',
      );

      await _fcmTokenStorage.saveToken(token);
      return Result.success(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<void> clearSavedFcmToken() async {
    await _fcmTokenStorage.clear();
  }

  @override
  Future<void> sendTestNotification(String token) async {
    try {
      await makeRequest(
        () async {
          final type = NotificationType.values[Random().nextInt(NotificationType.values.length)];

          await _apiClient.sendTestNotification(
            NotificationTestRequest(
              notificationType: type,
              metadata: NotificationMetadata.current(token: token),
            ),
          );

          logger.d('Sent test notification of type $type to token $token');
        },
        label: 'sendTestNotification',
      );
    } on Exception catch (e) {
      logger.e('Failed to send test notification', e);
    }
  }
}
