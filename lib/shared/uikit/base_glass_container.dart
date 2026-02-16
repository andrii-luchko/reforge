import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class BaseGlassContainer extends StatelessWidget {
  const BaseGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderWidth = 1.0,
    this.borderColor,
    this.borderGradientColors,
    this.borderGradientStops,
    this.surfaceGradientColors,
    this.surfaceGradientStops,
    this.backgroundColor,
    this.glassEffectGradientAlignmentBegin = Alignment.centerLeft,
    this.glassEffectGradientAlignmentEnd = Alignment.centerRight,
    this.constraints,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final BorderRadiusGeometry borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final List<Color>? borderGradientColors;
  final List<double>? borderGradientStops;
  final List<Color>? surfaceGradientColors;
  final List<double>? surfaceGradientStops;
  final Color? backgroundColor;
  final BoxConstraints? constraints;
  final AlignmentGeometry glassEffectGradientAlignmentBegin;
  final AlignmentGeometry glassEffectGradientAlignmentEnd;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? Colors.white.withValues(alpha: 0.1);

    final borderGradient = borderGradientColors == null
        ? null
        : GradientBoxBorder(
            width: borderWidth,
            gradient: LinearGradient(
              begin: glassEffectGradientAlignmentBegin,
              end: glassEffectGradientAlignmentEnd,
              stops: borderGradientStops,
              colors: borderGradientColors!,
            ),
          );

    final surfaceGradient = surfaceGradientColors == null
        ? null
        : LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            stops: surfaceGradientStops,
            colors: surfaceGradientColors!,
          );

    final effectiveBackgroundColor = backgroundColor ?? Colors.black.withValues(alpha: 0.1);

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: BoxBorder.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: borderGradient,
          gradient: surfaceGradient,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
