import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.package,
    required this.isSelected,
    this.onTap,
    this.isCurrentPlan = false,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.annualSavings,
    super.key,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCurrentPlan;
  final EdgeInsetsGeometry? margin;

  final double? annualSavings;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final tag = isCurrentPlan ? t.subscription.currentPlan : package.periodType.displayTag(t);

    final formattedAnnualSavings = annualSavings == null ? '' : package.formattedPrice(annualSavings!);

    return PressableAnimation(
      scaleAmount: 0.98,
      onTap: isCurrentPlan ? () {} : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.appTheme.beige900,
              border: GradientBoxBorder(
                gradient: LinearGradient.lerp(
                  appTheme.cardNavigation,
                  appTheme.selectedGradient,
                  isSelected ? 1.0 : 0.0,
                )!,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      package.periodType.displayName(t),
                      style: subheadH3Medium.copyWith(color: appTheme.beige100),
                    ),
                    const Spacer(),
                    if (package.trialInfo != null)
                      Text(
                        '(after ${package.trialInfo?.periodParsed ?? '14'})',
                        style: subheadH8Semibold.copyWith(color: appTheme.beige700),
                      ),
                    if (package.trialInfo != null) const SizedBox(width: 8),
                    Text(
                      package.displayPrice,
                      style: subheadH4Semibold.copyWith(color: appTheme.beige100),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        package.periodType.description(t, formattedAnnualSavings),
                        style: subheadH6Regular.copyWith(color: appTheme.beige700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      package.periodType.displayPeriod(t),
                      style: subheadH6Regular.copyWith(color: appTheme.beige700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: -23,
              left: 20,
              child: AppTag(
                text: tag,
              ),
            ),
        ],
      ),
    );
  }
}
