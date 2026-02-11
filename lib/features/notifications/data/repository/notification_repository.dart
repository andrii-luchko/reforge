import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/mock/notification_generator.dart';

abstract interface class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<void>> markNotificationAsRead(int id);
  Future<Result<void>> markAllAsRead();
}

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final notifications = NotificationGenerator.generateMocks(10)..sort((a, b) => b.date.compareTo(a.date));
      return Result.success(notifications);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> markNotificationAsRead(int id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
