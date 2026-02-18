import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SubscriptionLifetimeStatusCard extends StatelessWidget {
  const SubscriptionLifetimeStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appTheme.beige900,
        border: GradientBoxBorder(
          gradient: context.appTheme.selectedGradient,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.subscription.lifetimeStatus,
              style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
            ),
          ),
        ],
      ),
    );
  }
}
