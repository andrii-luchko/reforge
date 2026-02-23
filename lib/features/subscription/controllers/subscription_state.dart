part of 'subscription_cubit.dart';

@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();
  const factory SubscriptionState({
    SubscriptionOfferings? offerings,
    SubscriptionEntity? currentSubscription,
    @Default(false) bool isLoading,
    @Default(false) bool isPurchasing,
    String? error,
  }) = _SubscriptionState;

  bool get hasActiveSubscription => currentSubscription != null && currentSubscription!.isActive;

  SubscriptionPackage? get currentPackage => currentSubscription?.matchedPackage;

  bool get hasLifetime => currentPackage?.periodType == SubscriptionPeriodType.lifetime;

  double? getAnnualSavings() {
    final annual = offerings?.packages.firstWhereOrNull((p) => p.periodType == .annual);
    final monthly = offerings?.packages.firstWhereOrNull((p) => p.periodType == .monthly);
    if (annual == null || monthly == null) return null;
    final monthlyPrice = monthly.price;
    final annualPrice = annual.price;

    final savings = (monthlyPrice * 12) - annualPrice;

    if (savings <= 0) return 0;

    return savings;
  }
}
