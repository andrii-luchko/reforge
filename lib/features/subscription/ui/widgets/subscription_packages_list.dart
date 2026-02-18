import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list_content.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
      child: showSkeleton
          ? const SubscriptionPackagesSkeleton()
          : state.offerings != null
          ? SubscriptionPackagesListContent(
              packages: state.offerings!.packages,
              selectedPackage: selectedPackage,
              currentPackage: state.currentPackage,
              onPackageSelected: onPackageSelected,
            )
          : const SliverMainAxisGroup(slivers: []),
    );
  }
}
