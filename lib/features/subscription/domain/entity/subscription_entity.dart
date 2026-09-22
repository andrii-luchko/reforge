import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';

/// Current subscription status of the user.
class SubscriptionEntity {
  const SubscriptionEntity({
    this.expirationDate,
    this.periodType = SubscriptionPeriodType.unknown,
    this.store = SubscriptionStore.unknown,
  });

  final DateTime? expirationDate;
  final SubscriptionPeriodType periodType;
  final SubscriptionStore store;

  bool get isLifetime => periodType == SubscriptionPeriodType.lifetime;

  @override
  String toString() {
    return 'SubscriptionEntity(expirationDate: $expirationDate, periodType: $periodType, store: $store)';
  }
}

enum SubscriptionStore {
  appStore,
  macAppStore,
  playStore,
  stripe,
  promotional,
  amazon,
  revenueCatBilling,
  paddle,
  testStore,
  external,
  galaxy,
  unknown,
}
