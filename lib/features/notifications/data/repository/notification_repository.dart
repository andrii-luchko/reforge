import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/mock/notification_generator.dart';

abstract interface class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<void>> markNotificationAsRead(int id);
  Future<Result<void>> markAllAsRead();
}

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl with RepositoryErrorHandler implements NotificationRepository {
  NotificationRepositoryImpl(this._firebaseMessaging);

  final FirebaseMessaging _firebaseMessaging;

  Future<void> getNotifi() async {
    _firebaseMessaging.requestPermission();
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await makeRequest(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          final list = NotificationGenerator.generateMocks(10)..sort((a, b) => b.date.compareTo(a.date));
          return list;
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
        () => Future.delayed(const Duration(seconds: 1)),
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
        () => Future.delayed(const Duration(seconds: 1)),
        label: 'markNotificationAsRead',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
