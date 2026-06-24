// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/notifications/domain/enum/notification_permission_status.dart';

@injectable
class PermissionDatasource {
  /// Checks the current status of notification and exact alarm permissions
  /// without triggering a system prompt.
  Future<NotificationPermissionStatus> checkNotificationPermissions() async {
    try {
      final notificationStatus = await Permission.notification.status;

      // If Android, we must also check the exact alarm status
      if (Platform.isAndroid) {
        final alarmStatus = await Permission.scheduleExactAlarm.status;

        // If either is denied, we consider the feature unavailable
        if (!notificationStatus.isGranted || !alarmStatus.isGranted) {
          return _mapStatus(notificationStatus, isAlarmGranted: alarmStatus.isGranted);
        }
      }

      return _mapStatus(notificationStatus);
    } catch (e, stackTrace) {
      logger.e('Error checking notification permissions', e, stackTrace);
      return NotificationPermissionStatus.denied;
    }
  }

  /// Explicitly requests notification and exact alarm permissions.
  /// Triggers system dialogs if permissions are not yet determined.
  Future<NotificationPermissionStatus> requestNotificationPermissions() async {
    try {
      // 1. Request general notification permission
      final notificationStatus = await Permission.notification.request();

      if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
        logger.w('Notifications denied by user.');
        return NotificationPermissionStatus.denied;
      }

      // 2. Request Exact Alarm permission (Android 12+ specific)
      if (Platform.isAndroid) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (alarmStatus.isDenied) {
          alarmStatus = await Permission.scheduleExactAlarm.request();
        }

        if (!alarmStatus.isGranted) {
          logger.w('Exact alarms denied. Scheduled notifications will not work.');
          return NotificationPermissionStatus.denied;
        }
      }

      return _mapStatus(notificationStatus);
    } catch (e, stackTrace) {
      logger.e('Error requesting notification permissions', e, stackTrace);
      return NotificationPermissionStatus.denied;
    }
  }

  /// Private helper to map permission_handler Status to Domain Status
  NotificationPermissionStatus _mapStatus(
    PermissionStatus status, {
    bool isAlarmGranted = true,
  }) {
    if (!isAlarmGranted) return NotificationPermissionStatus.denied;

    if (status.isGranted) return NotificationPermissionStatus.authorized;
    if (status.isProvisional) return NotificationPermissionStatus.provisional;
    if (status.isDenied || status.isPermanentlyDenied) {
      return NotificationPermissionStatus.denied;
    }

    return NotificationPermissionStatus.notDetermined;
  }
}
