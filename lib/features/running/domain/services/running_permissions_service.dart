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
    final permission = Platform.isIOS ? Permission.sensors : Permission.activityRecognition;

    final status = await permission.request();

    return status.isGranted;
  }

  Future<bool> requestGpsPermission() async {
    final status = await Permission.location.request();
    logger.d('RunningPermissionsService: Location status = $status');

    // We can also request LocationAlways if needed for background tracking.
    // For now, simple location is requested.
    return status.isGranted || status.isLimited;
  }
}
