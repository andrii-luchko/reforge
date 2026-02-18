import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/rising_aura_effect.dart';

class SubscriptionLifetimeStatusCard extends StatelessWidget {
  const SubscriptionLifetimeStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return RisingAuraEffect(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.beige900,
          border: GradientBoxBorder(
            gradient: appTheme.selectedGradient,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.images.icons.medal,
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(appTheme.beige100, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.subscription.lifetimeTitle,
                    style: subheadH1Medium.copyWith(color: appTheme.beige100),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.subscription.lifetimeSubtitle,
                    style: subheadH6Regular.copyWith(color: appTheme.beige700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
