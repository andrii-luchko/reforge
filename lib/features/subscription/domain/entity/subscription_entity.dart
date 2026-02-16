/// Current subscription status of the user.
class SubscriptionEntity {
  const SubscriptionEntity({
    required this.isActive,
    this.expirationDate,
    this.entitlementId,
    this.productIdentifier,
    this.productPlanIdentifier,
  });

  final bool isActive;
  final DateTime? expirationDate;
  final String? entitlementId;
  final String? productIdentifier;
  final String? productPlanIdentifier;
}
