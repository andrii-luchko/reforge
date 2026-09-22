import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';

const reforgePremiumEntitlementId = 'Reforge Premium';
const reforgeLifetimeProductIds = {
  'com.reforgestudios.reforge.android.lifetime',
  'com.reforgestudios.reforge.ios.lifetime',
  'lifetime',
};

SubscriptionEntity? mapCustomerInfo(CustomerInfo info) {
  final entitlement = info.entitlements.active[reforgePremiumEntitlementId];
  if (entitlement == null || !entitlement.isActive) return null;
  DateTime? expirationDate;
  if (entitlement.expirationDate != null) {
    expirationDate = DateTime.tryParse(entitlement.expirationDate!);
  }
  return SubscriptionEntity(
    expirationDate: expirationDate,
    periodType: reforgeLifetimeProductIds.contains(entitlement.productIdentifier)
        ? SubscriptionPeriodType.lifetime
        : SubscriptionPeriodType.unknown,
    store: _mapStore(entitlement.store),
  );
}

SubscriptionStore _mapStore(Store store) {
  return switch (store) {
    Store.appStore => SubscriptionStore.appStore,
    Store.macAppStore => SubscriptionStore.macAppStore,
    Store.playStore => SubscriptionStore.playStore,
    Store.stripe => SubscriptionStore.stripe,
    Store.promotional => SubscriptionStore.promotional,
    Store.amazon => SubscriptionStore.amazon,
    Store.rcBilling => SubscriptionStore.revenueCatBilling,
    Store.paddle => SubscriptionStore.paddle,
    Store.testStore => SubscriptionStore.testStore,
    Store.externalStore => SubscriptionStore.external,
    Store.galaxy => SubscriptionStore.galaxy,
    Store.unknownStore => SubscriptionStore.unknown,
  };
}
