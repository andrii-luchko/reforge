import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'subscription_card.dart';
import 'subscription_card_skeleton.dart';

class SubscriptionPackagesList extends StatelessWidget {
  const SubscriptionPackagesList({
    required this.state,
    required this.selectedPackage,
    required this.onPackageSelected,
    super.key,
  });

  final SubscriptionState state;
  final SubscriptionPackage? selectedPackage;
  final ValueChanged<SubscriptionPackage> onPackageSelected;

  @override
  Widget build(BuildContext context) {
    final showSkeleton = state.isLoading && state.offerings == null;

    return SliverSkeletonizer(
      enabled: showSkeleton,
      child: SliverMainAxisGroup(
        slivers: [
          const SliverPadding(padding: EdgeInsets.all(8)),
          if (showSkeleton) ..._buildSkeletonSlivers(),
          if (!showSkeleton && state.offerings != null)
            ..._buildPackagesSlivers(),
        ],
      ),
    );
  }

  List<Widget> _buildSkeletonSlivers() {
    return List.generate(
      3,
      (_) => const SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 8),
        sliver: SliverToBoxAdapter(
          child: SubscriptionCardSkeleton(),
        ),
      ),
    );
  }

  List<Widget> _buildPackagesSlivers() {
    final offerings = state.offerings!;
    if (offerings.packages.isEmpty) {
      return [];
    }
    return offerings.packages
        .map(
          (package) => SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverToBoxAdapter(
              child: SubscriptionCard(
                package: package,
                isSelected: selectedPackage?.id == package.id,
                onTap: () => onPackageSelected(package),
              ),
            ),
          ),
        )
        .toList();
  }
}
