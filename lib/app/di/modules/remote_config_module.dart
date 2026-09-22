// ignore_for_file: prefer_match_file_name

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';

@module
abstract class RemoteConfigModule {
  @preResolve
  Future<FirebaseRemoteConfig> get remoteConfig async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    const fetchInterval = kDebugMode ? Duration.zero : Duration(hours: 1);

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: fetchInterval,
      ),
    );

    await remoteConfig.setDefaults(const {'paywall_skip_button_enabled': false});

    try {
      await remoteConfig.fetchAndActivate();
    } on Object catch (e, s) {
      logger.w('RemoteConfigModule: failed to fetch and activate remote config', e, s);
    }

    return remoteConfig;
  }
}
