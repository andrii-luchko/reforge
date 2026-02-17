// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  String toString() {
    return 'SubscriptionEntity(isActive: $isActive, expirationDate: $expirationDate, entitlementId: $entitlementId, productIdentifier: $productIdentifier, productPlanIdentifier: $productPlanIdentifier)';
  }
}
