import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_card.dart';

class SubscriptionPackagesListContent extends StatelessWidget {
  const SubscriptionPackagesListContent({
    required this.packages,
    required this.selectedPackage,
    required this.currentPackage,
    required this.onPackageSelected,
    this.annualSavings,
    super.key,
  });

  final List<SubscriptionPackage> packages;
  final SubscriptionPackage? selectedPackage;
  final SubscriptionPackage? currentPackage;
  final ValueChanged<SubscriptionPackage> onPackageSelected;

  final double? annualSavings;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: packages
          .map(
            (package) => SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverToBoxAdapter(
                child: SubscriptionCard(
                  package: package,
                  isSelected: selectedPackage?.id == package.id,
                  isCurrentPlan: package == currentPackage,
                  onTap: () => onPackageSelected(package),
                  annualSavings: annualSavings,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
