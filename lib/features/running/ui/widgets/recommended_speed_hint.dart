import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class RecommendedSpeedHint extends StatelessWidget {
  const RecommendedSpeedHint({required this.recommendedSpeed, super.key});

  final double recommendedSpeed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        border: Border.all(color: appTheme.strokeCard),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            style: subheadH5Medium.copyWith(color: appTheme.beige600),
            children: [
              TextSpan(
                text: t.running.active.speed_hint,
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: recommendedSpeed.toStringAsFixed(1),
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
