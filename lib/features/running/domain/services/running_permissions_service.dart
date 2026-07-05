import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';

@lazySingleton
class RunningPermissionsService {
  /// Requests the necessary permissions for the given [RunningMode].
  /// Returns `true` if permissions are granted or already granted,
  /// `false` if denied or permanently denied.
  Future<bool> requestPermissionsForMode(RunningMode mode) async {
    return switch (mode) {
      RunningMode.pedometer => requestPedometerPermission(),
      RunningMode.gps => requestGpsPermission(),
    };
  }

  Future<bool> requestPedometerPermission() async {
    final sensorPermission = Platform.isIOS ? Permission.sensors : Permission.activityRecognition;
    final sensorStatus = await sensorPermission.request();

    if (Platform.isIOS) {
      // iOS requires location to keep the pedometer isolate alive in the background
      final locationStatus = await Permission.location.request();
      final isGranted = sensorStatus.isGranted && (locationStatus.isGranted || locationStatus.isLimited);
      if (isGranted) {
        await _requestNotificationPermission();
      }
      return isGranted;
    }

    if (sensorStatus.isGranted) {
      await _requestNotificationPermission();
    }

    return sensorStatus.isGranted;
  }

  Future<bool> requestGpsPermission() async {
    final status = await Permission.location.request();
    logger.d('RunningPermissionsService: Location status = $status');

    final isGranted = status.isGranted || status.isLimited;
    if (isGranted) {
      await _requestNotificationPermission();
    }

    return isGranted;
  }

  Future<void> _requestNotificationPermission() async {
    // Required on Android 13+ for the foreground service notification.
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }
}
