import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/settings/data/system_info.dart';

abstract interface class SystemInfoServiceI {
  String get appVersion;
  Future<SystemInfo?> collectSystemInfo();
}

@Injectable(as: SystemInfoServiceI)
class SystemInfoService implements SystemInfoServiceI {
  SystemInfoService(this._deviceInfoPlugin, this._packageInfo);

  final DeviceInfoPlugin _deviceInfoPlugin;
  final PackageInfo _packageInfo;

  @override
  String get appVersion => _packageInfo.version;

  @override
  Future<SystemInfo?> collectSystemInfo() async {
    try {
      final deviceInfo = await _deviceInfoPlugin.deviceInfo;

      return SystemInfo(
        appVersion: _packageInfo.version,
        buildNumber: _packageInfo.buildNumber,
        deviceModel: _getDeviceModel(deviceInfo),
        platform: Platform.isAndroid ? 'android' : 'ios',
        osVersion: _getOSVersion(deviceInfo),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      logger.e('Error collecting device information:{$e}', e, s);

      return SystemInfo(
        appVersion: _packageInfo.version,
        buildNumber: _packageInfo.buildNumber,
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceModel: 'Unknown',
        osVersion: 'Unknown',
      );
    }
  }

  String _getDeviceModel(BaseDeviceInfo deviceInfo) {
    if (deviceInfo is AndroidDeviceInfo) return deviceInfo.model;
    if (deviceInfo is IosDeviceInfo) return deviceInfo.model;

    return 'Unknown';
  }

  String _getOSVersion(BaseDeviceInfo deviceInfo) {
    if (deviceInfo is AndroidDeviceInfo) return deviceInfo.version.release;
    if (deviceInfo is IosDeviceInfo) return deviceInfo.systemVersion;

    return 'Unknown';
  }
}
