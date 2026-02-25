import 'package:device_info_plus/device_info_plus.dart';

import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@module
abstract class SystemInfoModule {
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  @preResolve
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();
}
