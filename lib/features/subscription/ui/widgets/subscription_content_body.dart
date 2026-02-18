import 'package:flutter/material.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_lifetime_status_card.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_recurring_status_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

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
              expirationDate: state.currentSubscription!.expirationDate,
              managementUrl: state.currentSubscription!.managementUrl,
            ),
          ),
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

class SubscriptionFooterAction extends StatelessWidget {
  const SubscriptionFooterAction({
    required this.buttonLabel,
    required this.onPressed,
    required this.onRestorePurchases,
    super.key,
  });

  final String buttonLabel;
  final VoidCallback? onPressed;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryButton(
          text: buttonLabel,
          onPressed: onPressed,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThirtyButton(
              text: 'Restore Purchases',
              onPressed: onRestorePurchases,
              style: subheadH6Medium,
            ),

            ThirtyButton(
              text: 'Terms',
              onPressed: () => LaunchUrl.launchAppLink(Env.termsOfUseUrl),
              style: subheadH6Medium,
            ),

            ThirtyButton(
              text: 'Privacy',
              onPressed: () => LaunchUrl.launchAppLink(Env.privacyPolicyUrl),
              style: subheadH6Medium,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
