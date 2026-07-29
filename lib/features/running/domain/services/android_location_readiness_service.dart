import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';

/// Requests the Android system settings required for high-accuracy location.
///
/// Unlike a position stream, this does not wait for a GPS fix. Android's
/// `SettingsClient` either confirms that the requested settings are already
/// available or displays its resolution dialog while the app has an Activity.

@injectable
class AndroidLocationReadinessService {
  static const _channel = MethodChannel('com.reforgestudios.reforge/location_readiness');

  Future<bool> ensureHighAccuracyEnabled() async {
    if (!Platform.isAndroid) return true;

    try {
      return await _channel.invokeMethod<bool>('ensureHighAccuracyEnabled') ?? false;
    } on PlatformException catch (error, stackTrace) {
      logger.e('Android location readiness check failed', error, stackTrace);
      return false;
    }
  }
}
