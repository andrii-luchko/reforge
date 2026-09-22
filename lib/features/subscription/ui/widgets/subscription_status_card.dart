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
          spacing: 24,
          children: [
            Text(
              t.subscription.premiumTitle,
              style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
            ),
            Text(
              subscription.isLifetime ? t.subscription.lifetimeStatus : t.subscription.activeStatus,
              style: subheadH4Semibold.copyWith(color: context.appTheme.beige700),
            ),
            if (!subscription.isLifetime && subscription.expirationDate != null)
              Text(
                t.subscription.activeUntil(date: subscription.expirationDate!.toDateTimeString()),
                style: subheadH4Semibold.copyWith(color: context.appTheme.beige700),
              ),
            if (subscription.store != SubscriptionStore.unknown)
              Text(
                t.subscription.purchasedThrough(store: _storeName(subscription.store)),
                style: subheadH4Semibold.copyWith(color: context.appTheme.beige700),
              ),
            SecondaryButton(
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
          ],
        ),
      ),
    );
  }

  String _storeName(SubscriptionStore store) {
    return switch (store) {
      SubscriptionStore.appStore => t.subscription.store.appStore,
      SubscriptionStore.macAppStore => t.subscription.store.macAppStore,
      SubscriptionStore.playStore => t.subscription.store.playStore,
      SubscriptionStore.stripe => t.subscription.store.stripe,
      SubscriptionStore.promotional => t.subscription.store.promotional,
      SubscriptionStore.amazon => t.subscription.store.amazon,
      SubscriptionStore.revenueCatBilling => t.subscription.store.revenueCatBilling,
      SubscriptionStore.paddle => t.subscription.store.paddle,
      SubscriptionStore.testStore => t.subscription.store.testStore,
      SubscriptionStore.external => t.subscription.store.external,
      SubscriptionStore.galaxy => t.subscription.store.galaxy,
      SubscriptionStore.unknown => t.subscription.store.unknown,
    };
  }
}
