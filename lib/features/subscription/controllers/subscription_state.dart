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

  bool isCurrentPackage(SubscriptionPackage package) {
    final entity = currentSubscription;
    if (entity == null) return false;
    // Android: productPlanIdentifier ?? productIdentifier
    final purchasedId = Platform.isAndroid
        ? (entity.productPlanIdentifier ?? entity.productIdentifier)
        : entity.productIdentifier;
    return purchasedId == package.productIdentifier;
  }
}
