import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_footer_actions.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_lifetime_status_card.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_recurring_status_card.dart';
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

  String _buttonLabel() {
    if (state.hasLifetime) return '';
    if (state.hasActiveSubscription && state.currentPackage != null) {
      if (selectedPackage == state.currentPackage) {
        return t.subscription.currentPlan;
      }
      return selectedPackage?.periodType.isUpgradeFrom(state.currentPackage!.periodType) ?? false
          ? t.subscription.upgrade
          : t.subscription.changePlan;
    }
    return t.common.continue_button;
  }

  bool _canPurchase() {
    if (state.hasLifetime) return false;
    if (selectedPackage == null) return false;
    if (state.hasActiveSubscription && state.currentPackage != null) {
      if (selectedPackage == state.currentPackage) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (state.hasLifetime) {
      return const SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: SubscriptionLifetimeStatusCard(),
          ),
        ],
      );
    }

    if (state.hasActiveSubscription && state.currentPackage != null) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: SubscriptionRecurringStatusCard(
              currentPackage: state.currentPackage!,
              expirationDate: state.currentSubscription!.expirationDate,
              managementUrl: state.currentSubscription!.managementUrl,
            ),
          ),
          const SliverPadding(padding: .only(bottom: 24)),
          SubscriptionPackagesList(
            state: state,
            selectedPackage: selectedPackage,
            onPackageSelected: onPackageSelected,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SubscriptionFooterAction(
              buttonLabel: _buttonLabel(),
              onPressed: _canPurchase() ? onPurchase : null,
              onRestorePurchases: onRestorePurchases,
            ),
          ),

          const SliverPadding(padding: .only(bottom: 24)),
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
        SliverFillRemaining(
          hasScrollBody: false,
          child: SubscriptionFooterAction(
            buttonLabel: _buttonLabel(),
            onPressed: _canPurchase() ? onPurchase : null,
            onRestorePurchases: onRestorePurchases,
          ),
        ),
      ],
    );
  }
}
