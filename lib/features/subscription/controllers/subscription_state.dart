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
}
