import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

/// Current subscription status of the user.
class SubscriptionEntity {
  const SubscriptionEntity({
    this.expirationDate,
    this.periodType = SubscriptionPeriodType.unknown,
    this.store = SubscriptionStore.unknown,
    this.status = SubscriptionStatus.active,
  });

  final DateTime? expirationDate;
  final SubscriptionPeriodType periodType;
  final SubscriptionStore store;
  final SubscriptionStatus status;

  bool get isLifetime => periodType == SubscriptionPeriodType.lifetime;

  @override
  String toString() {
    return 'SubscriptionEntity(expirationDate: $expirationDate, periodType: $periodType, store: $store, status: $status)';
  }
}

enum SubscriptionStatus {
  active,
  trial,
  introductory,
  canceled,
  billing,
  lifetime,
}

extension SubscriptionStatusX on SubscriptionStatus {
  String displayName(Translations t) {
    return switch (this) {
      SubscriptionStatus.active => t.subscription.status.active,
      SubscriptionStatus.trial => t.subscription.status.trial,
      SubscriptionStatus.introductory => t.subscription.status.introductory,
      SubscriptionStatus.canceled => t.subscription.status.canceled,
      SubscriptionStatus.billing => t.subscription.status.billing,
      SubscriptionStatus.lifetime => t.subscription.status.lifetime,
    };
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

extension SubscriptionStoreX on SubscriptionStore {
  String displayName(Translations t) {
    return switch (this) {
      SubscriptionStore.appStore => t.subscription.store.appStore,
      SubscriptionStore.macAppStore => t.subscription.store.macAppStore,
      SubscriptionStore.playStore => t.subscription.store.playStore,
      SubscriptionStore.stripe => t.subscription.store.stripe,
      SubscriptionStore.promotional => t.subscription.store.promotional,
      SubscriptionStore.amazon => t.subscription.store.amazon,
      SubscriptionStore.revenueCatBilling => t.subscription.store.revenueCatBilling,
      SubscriptionStore.paddle => t.subscription.store.paddle,
      SubscriptionStore.testStore => t.subscription.store.testStore,
      SubscriptionStore.external => t.subscription.store.external,
      SubscriptionStore.galaxy => t.subscription.store.galaxy,
      SubscriptionStore.unknown => t.subscription.store.unknown,
    };
  }
}
