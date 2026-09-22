import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_footer_actions.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_status_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SubscriptionContentBody extends StatelessWidget {
  const SubscriptionContentBody({
    required this.state,
    required this.selectedPackage,
    required this.onPackageSelected,
    required this.onPurchase,
    required this.onRestorePurchases,

    super.key,
  });

  final SubscriptionState state;
  final SubscriptionPackage? selectedPackage;
  final ValueChanged<SubscriptionPackage> onPackageSelected;
  final VoidCallback onPurchase;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    if (state.accessStatus == SubscriptionAccessStatus.checking) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.accessStatus == SubscriptionAccessStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.subscription.loadErrorSubtitle),
              TextButton(
                onPressed: () => context.read<SubscriptionCubit>().retry(),
                child: Text(t.subscription.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (state.hasActiveSubscription) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: SubscriptionStatusCard(
              subscription: state.currentSubscription!,
            ).animateEntrance(),
          ),
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SubscriptionPackagesList(
          state: state,
          selectedPackage: selectedPackage,
          onPackageSelected: onPackageSelected,
        ),
        if (state.offerings == null || state.offerings!.packages.isEmpty)
          SliverToBoxAdapter(
            child: TextButton(
              onPressed: () => context.read<SubscriptionCubit>().loadOfferings(),
              child: Text(t.subscription.tryAgain),
            ),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: SubscriptionFooterAction(
            buttonLabel: t.common.continue_button,
            onPressed: selectedPackage != null ? onPurchase : null,
            onRestorePurchases: onRestorePurchases,
          ),
        ),
      ],
    );
  }
}
