import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_lifetime_status_card.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_recurring_status_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

class SubscriptionContentBody extends StatelessWidget {
  const SubscriptionContentBody({
    required this.state,
    required this.selectedPackage,
    required this.onPackageSelected,
    required this.onPurchase,
    super.key,
  });

  final SubscriptionState state;
  final SubscriptionPackage? selectedPackage;
  final ValueChanged<SubscriptionPackage> onPackageSelected;
  final VoidCallback onPurchase;

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
    return t.common.save_changes_button;
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
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SecondaryButton(
                text: _buttonLabel(),
                onPressed: _canPurchase() ? onPurchase : null,
              ),
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
    super.key,
  });

  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .end,
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
              onPressed: () {
                Purchases.restorePurchases();
              },
            ),

            ThirtyButton(
              text: 'Terms',
              onPressed: () {
                LaunchUrl.launchAppLink(Env.termsOfUseUrl);

                ;
              },
            ),

            ThirtyButton(
              text: 'Privacy',
              onPressed: () {
                LaunchUrl.launchAppLink(Env.privacyPolicyUrl);
              },
            ),
          ],
        ),
      ],
    );
  }
}
