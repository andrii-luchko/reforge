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
  final isLifetime = reforgeLifetimeProductIds.contains(entitlement.productIdentifier);
  return SubscriptionEntity(
    expirationDate: expirationDate,
    periodType: isLifetime ? SubscriptionPeriodType.lifetime : SubscriptionPeriodType.unknown,
    store: _mapStore(entitlement.store),
    status: _mapStatus(entitlement, isLifetime: isLifetime),
  );
}

SubscriptionStatus _mapStatus(EntitlementInfo entitlement, {required bool isLifetime}) {
  if (isLifetime) return SubscriptionStatus.lifetime;
  if (entitlement.billingIssueDetectedAt != null) return SubscriptionStatus.billing;
  if (entitlement.unsubscribeDetectedAt != null) return SubscriptionStatus.canceled;

  return switch (entitlement.periodType) {
    PeriodType.trial => SubscriptionStatus.trial,
    PeriodType.intro => SubscriptionStatus.introductory,
    PeriodType.normal || PeriodType.prepaid || PeriodType.unknown => SubscriptionStatus.active,
  };
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
