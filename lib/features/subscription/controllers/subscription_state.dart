part of 'subscription_cubit.dart';

enum SubscriptionAccessStatus { checking, active, inactive, error }

@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();
  const factory SubscriptionState({
    SubscriptionOfferings? offerings,
    SubscriptionEntity? currentSubscription,
    @Default(SubscriptionAccessStatus.checking) SubscriptionAccessStatus accessStatus,
    @Default(false) bool isLoading,
    @Default(false) bool isPurchasing,
    String? error,
  }) = _SubscriptionState;

  bool get hasActiveSubscription => accessStatus == SubscriptionAccessStatus.active;
}
