import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';

/// Current subscription status of the user.
class SubscriptionEntity {
  const SubscriptionEntity({
    required this.isActive,
    this.expirationDate,
    this.entitlementId,
    this.productIdentifier,
    this.productPlanIdentifier,
    this.matchedPackage,
    this.managementUrl,
  });

  final bool isActive;
  final DateTime? expirationDate;
  final String? entitlementId;
  final String? productIdentifier;
  final String? productPlanIdentifier;
  final SubscriptionPackage? matchedPackage;
  final String? managementUrl;

  @override
  String toString() {
    return 'SubscriptionEntity(isActive: $isActive, expirationDate: $expirationDate, entitlementId: $entitlementId, productIdentifier: $productIdentifier, productPlanIdentifier: $productPlanIdentifier)';
  }
}
