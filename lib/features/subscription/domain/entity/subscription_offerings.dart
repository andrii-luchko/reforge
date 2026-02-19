import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';

/// Available subscription offerings and packages.
class SubscriptionOfferings {
  const SubscriptionOfferings({
    required this.packages,
    this.currentOfferingId,
  });

  final List<SubscriptionPackage> packages;
  final String? currentOfferingId;
}
