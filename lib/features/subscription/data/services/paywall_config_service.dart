import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PaywallConfigService {
  PaywallConfigService(this._remoteConfig);

  static const _skipButtonEnabledKey = 'paywall_skip_button_enabled';

  final FirebaseRemoteConfig _remoteConfig;

  bool get skipButtonEnabled => _remoteConfig.getBool(_skipButtonEnabledKey);
}
