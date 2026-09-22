import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({
    required this.subscription,
    super.key,
  });

  final SubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
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
          spacing: 16,
          children: [
            Row(
              spacing: 16,

              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  t.subscription.premiumTitle,
                  style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                ),
                AppTag(
                  text: subscription.status.displayName(t),
                  textStyle: subheadH6Medium.copyWith(fontSize: 12),
                  padding: const .symmetric(horizontal: 8, vertical: 4),
                  fitted: true,
                ),
              ],
            ),
            if (!subscription.isLifetime && subscription.expirationDate != null)
              Text(
                t.subscription.activeUntil(date: subscription.expirationDate!.toDotString()),
                style: subheadH4Semibold.copyWith(color: context.appTheme.beige700),
              ),
            if (subscription.store != SubscriptionStore.unknown)
              Text(
                t.subscription.purchasedThrough(store: subscription.store.displayName(t)),
                style: subheadH6Regular.copyWith(color: context.appTheme.beige700),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SecondaryButton(
                text: t.subscription.manageSubscription,
                onPressed: () async {
                  final cubit = context.read<SubscriptionCubit>();
                  await RevenueCatUI.presentCustomerCenter(
                    onRestoreCompleted: (_) => unawaited(cubit.checkSubscriptionStatus()),
                    onPromotionalOfferSucceeded: (_, _, _) => unawaited(cubit.checkSubscriptionStatus()),
                  );
                  if (context.mounted) await cubit.checkSubscriptionStatus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
