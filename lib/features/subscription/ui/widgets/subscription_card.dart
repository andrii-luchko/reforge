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
    required this.onTap,
    super.key,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  static const String _description = 'Unlock all features and get exclusive content with our premium subscription.';

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final tag = package.periodType.displayTag(t);
    return PressableAnimation(
      scaleAmount: 0.98,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
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
                      package.title,
                      style: subheadH3Medium.copyWith(color: appTheme.beige100),
                    ),
                    const Spacer(),
                    if (package.trialInfo != null)
                      Text(
                        '(after ${package.trialInfo?.period ?? '14'})',
                        style: subheadH8Semibold.copyWith(color: appTheme.beige700),
                      ),
                    if (package.trialInfo != null) const SizedBox(width: 8),
                    Text(
                      package.displayPrice,
                      style: subheadH4Semibold.copyWith(color: appTheme.beige100),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _description,
                        style: subheadH6Regular.copyWith(color: appTheme.beige700),
                      ),
                    ),
                    const SizedBox(width: 3),
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
              top: -20,
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
