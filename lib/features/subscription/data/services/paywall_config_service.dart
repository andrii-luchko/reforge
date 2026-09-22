import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PaywallConfigService {
  PaywallConfigService(this._remoteConfig);

  static const _subscriptionRequiredKey = 'subscription_required';

  final FirebaseRemoteConfig _remoteConfig;

  bool get subscriptionRequired => _remoteConfig.getBool(_subscriptionRequiredKey);
}
