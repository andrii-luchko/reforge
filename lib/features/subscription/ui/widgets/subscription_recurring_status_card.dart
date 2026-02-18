import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_manage_button.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SubscriptionRecurringStatusCard extends StatelessWidget {
  const SubscriptionRecurringStatusCard({
    required this.expirationDate,
    this.managementUrl,
    super.key,
  });

  final DateTime? expirationDate;
  final String? managementUrl;

  @override
  Widget build(BuildContext context) {
    final dateText = expirationDate != null ? expirationDate!.toDateTimeString() : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appTheme.beige900,
        border: GradientBoxBorder(
          gradient: context.appTheme.cardNavigation,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscription.activeUntil(date: dateText),
            style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
          ),
          const SizedBox(height: 12),
          SubscriptionManageButton(managementUrl: managementUrl),
        ],
      ),
    );
  }
}
