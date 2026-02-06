import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius,
    this.padding,
    this.glassEffectGradientAlignmentBegin = Alignment.centerLeft,
    this.glassEffectGradientAlignmentEnd = Alignment.centerRight,
  });

  final Widget? child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry glassEffectGradientAlignmentBegin;
  final AlignmentGeometry glassEffectGradientAlignmentEnd;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = this.borderRadius ?? BorderRadius.circular(20);
    return BaseGlassContainer(
      borderRadius: borderRadius,
      padding: padding,

      borderColor: appTheme.beige100.withValues(alpha: 0.1),

      borderGradientColors: [
        Colors.transparent,
        appTheme.beige100,
        Colors.transparent,
      ],

      surfaceGradientColors: [
        appTheme.orange400.withValues(alpha: 0.2),
        Colors.transparent,
      ],

      backgroundColor: appTheme.beige900.withValues(alpha: 0.2),
      glassEffectGradientAlignmentBegin: glassEffectGradientAlignmentBegin,
      glassEffectGradientAlignmentEnd: glassEffectGradientAlignmentEnd,

      child: child,
    );
  }
}
