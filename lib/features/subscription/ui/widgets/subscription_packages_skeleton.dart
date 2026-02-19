import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubscriptionPackagesSkeleton extends StatelessWidget {
  const SubscriptionPackagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Skeleton.leaf(
              child: SubscriptionCard(
                package: SubscriptionPackagePlaceholder.placeholder,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Skeleton.leaf(
              child: SubscriptionCard(
                package: SubscriptionPackagePlaceholder.placeholder,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Skeleton.leaf(
              child: SubscriptionCard(
                package: SubscriptionPackagePlaceholder.placeholder,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
