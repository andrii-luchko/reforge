import 'package:flutter/material.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

import 'subscription_packages_list.dart';

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

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
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
              text: t.common.save_changes_button,
              onPressed: selectedPackage == null ? null : onPurchase,
            ),
          ),
        ),
      ],
    );
  }
}
