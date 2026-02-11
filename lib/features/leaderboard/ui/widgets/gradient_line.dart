import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

class GradientLine extends StatelessWidget {
  const GradientLine({
    this.gradient,
    super.key,
    this.height = 1.0,
    this.width,
    this.borderRadius,
  });

  final Gradient? gradient;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final gr =
        gradient ??
        LinearGradient(
          colors: [
            context.appTheme.beige100.withValues(alpha: 0),
            context.appTheme.beige100.withValues(alpha: 0.2),
            context.appTheme.beige100.withValues(alpha: 0.5),
            context.appTheme.beige100,
            context.appTheme.beige100.withValues(alpha: 0.5),
            context.appTheme.beige100.withValues(alpha: 0.2),
            context.appTheme.beige100.withValues(alpha: 0),
          ],
        );
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gr,
        borderRadius: borderRadius,
      ),
    );
  }
}
