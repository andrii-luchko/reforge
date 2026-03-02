import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_card.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/rising_aura_effect.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class SubscriptionRecurringStatusCard extends StatelessWidget {
  const SubscriptionRecurringStatusCard({
    required this.currentPackage,
    required this.expirationDate,
    this.managementUrl,
    super.key,
  });

  final SubscriptionPackage currentPackage;
  final DateTime? expirationDate;
  final String? managementUrl;

  @override
  Widget build(BuildContext context) {
    final dateText = expirationDate != null ? expirationDate!.toDateTimeString() : '—';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appTheme.beige900,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: context.appTheme.cardNavigation,
          border: Border.all(color: context.appTheme.strokeCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Text(
              t.subscription.currentPlan,
              style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
            ),
            Text(
              t.subscription.activeUntil(date: dateText),
              style: subheadH4Semibold.copyWith(color: context.appTheme.beige700),
            ),
            RisingAuraEffect(
              child: AbsorbPointer(
                child: SubscriptionCard(
                  package: currentPackage,
                  isSelected: true,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),

            SecondaryButton(
              text: t.subscription.manageSubscription,
              onPressed: RevenueCatUI.presentCustomerCenter,
            ),
          ],
        ),
      ),
    );
  }
}
