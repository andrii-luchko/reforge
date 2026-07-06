import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';

@lazySingleton
class RunningPermissionsService {
  /// Requests the necessary permissions for the given [RunningMode].
  Future<bool> requestPermissionsForMode(RunningMode mode) async {
    try {
      final isGranted = await switch (mode) {
        RunningMode.pedometer => _requestPedometerPermission(),
        RunningMode.gps => _requestGpsPermission(),
      };

      if (isGranted) {
        await _requestRequiredBackgroundNotifications();
      }

      return isGranted;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      logger.e('Failed to request permissions for mode: $mode', e, stackTrace);
      return false;
    }
  }

  Future<bool> _requestPedometerPermission() async {
    if (Platform.isIOS) {
      // iOS requires both sensors and location to keep the pedometer alive in background
      final sensorStatus = await Permission.sensors.request();
      final locationStatus = await Permission.location.request();

      return sensorStatus.isGranted && (locationStatus.isGranted || locationStatus.isLimited);
    }

    if (Platform.isAndroid) {
      final activityStatus = await Permission.activityRecognition.request();
      return activityStatus.isGranted;
    }

    return false;
  }

  Future<bool> _requestGpsPermission() async {
    final status = await Permission.location.request();
    logger.d('RunningPermissionsService: Location status = $status');
    return status.isGranted || status.isLimited;
  }

  Future<void> _requestRequiredBackgroundNotifications() async {
    if (Platform.isAndroid) {
      // Required on Android 13+ for the foreground service notification
      await Permission.notification.request();
    }
  }
}
