import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/services/android_location_readiness_service.dart';

@lazySingleton
class RunningPermissionsService {
  RunningPermissionsService({AndroidLocationReadinessService? locationReadinessService})
    : _locationReadinessService = locationReadinessService ?? AndroidLocationReadinessService();

  final AndroidLocationReadinessService _locationReadinessService;

  /// Requests the necessary permissions for the given [RunningMode].
  Future<bool> requestPermissionsForMode(RunningMode mode) async {
    try {
      final isGranted = await switch (mode) {
        RunningMode.treadmill => _requestTreadmillPermission(),
        RunningMode.gps => _requestGpsPermission(),
      };

      if (isGranted) {
        // This must happen while the mode picker is still backed by a visible
        // Activity. The native SettingsClient can then display its resolution
        // dialog without starting a location stream or waiting for a GPS fix.
        if (mode == RunningMode.gps && !await _locationReadinessService.ensureHighAccuracyEnabled()) {
          return false;
        }
        await _requestRequiredBackgroundNotifications();
      }

      return isGranted;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      logger.e('Failed to request permissions for mode: $mode', e, stackTrace);
      return false;
    }
  }

  Future<bool> _requestGpsPermission() async {
    final status = await Permission.location.request();
    logger.d('RunningPermissionsService: Location status = $status');
    return status.isGranted || status.isLimited;
  }

  Future<bool> _requestTreadmillPermission() async {
    if (Platform.isIOS) {
      // Core Location is used only to keep manual tracking alive while locked.
      final status = await Permission.location.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      // Manual metrics use no location or motion sensor. The foreground
      // service runs with location type but does not start a location stream.
      return true;
    }

    return false;
  }

  Future<void> _requestRequiredBackgroundNotifications() async {
    if (Platform.isAndroid) {
      // Required on Android 13+ for the foreground service notification
      await Permission.notification.request();
    }
  }
}
