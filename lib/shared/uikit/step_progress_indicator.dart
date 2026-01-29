import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
    this.spacing = 6.0,
  });

  final int currentStep;
  final int totalSteps;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotWidth = _calculateDotWidth(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSmoothIndicator(
              activeIndex: currentStep - 1,
              count: totalSteps,
              effect: ProgressiveDotsEffect(
                dotHeight: 6,
                radius: 20,
                dotWidth: dotWidth,
                spacing: spacing,

                activeDotColor: context.appTheme.orange500,
                dotColor: context.appTheme.beige800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                t.common.step_count(active: currentStep, total: totalSteps),

                style: subheadH5Medium.copyWith(color: context.appTheme.beige400),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateDotWidth(double maxWidth) {
    if (totalSteps <= 0) return 0;

    final totalSpacing = spacing * (totalSteps - 1);
    final width = (maxWidth - totalSpacing) / totalSteps;

    return width > 0 ? width : 0;
  }
}

class ProgressiveDotsEffect extends BasicIndicatorEffect {
  const ProgressiveDotsEffect({
    super.dotWidth = 16.0,
    super.dotHeight = 16.0,
    super.spacing = 8.0,
    super.radius = 16.0,
    super.dotColor,
    super.activeDotColor,
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
  });

  @override
  IndicatorPainter buildPainter(int count, double offset, DefaultIndicatorColors indicatorColors) {
    return _ProgressiveDotsPainter(
      count: count,
      offset: offset,
      effect: this,
      indicatorColors: indicatorColors,
    );
  }

  @override
  IndicatorEffect lerp(IndicatorEffect? other, double t) {
    if (other is! ProgressiveDotsEffect) return this;
    return ProgressiveDotsEffect(
      dotWidth: ui.lerpDouble(dotWidth, other.dotWidth, t)!,
      dotHeight: ui.lerpDouble(dotHeight, other.dotHeight, t)!,
      spacing: ui.lerpDouble(spacing, other.spacing, t)!,
      radius: ui.lerpDouble(radius, other.radius, t)!,
      strokeWidth: ui.lerpDouble(strokeWidth, other.strokeWidth, t)!,
      paintStyle: t < 0.5 ? paintStyle : other.paintStyle,
      dotColor: Color.lerp(dotColor, other.dotColor, t),
      activeDotColor: Color.lerp(activeDotColor, other.activeDotColor, t),
    );
  }
}

class _ProgressiveDotsPainter extends IndicatorPainter {
  _ProgressiveDotsPainter({
    required this.count,
    required double offset,
    required this.effect,
    required this.indicatorColors,
  }) : super(offset);

  final ProgressiveDotsEffect effect;
  final DefaultIndicatorColors indicatorColors;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final current = offset.floor();

    final progress = offset - current;

    final defaultDotColor = effect.dotColor ?? indicatorColors.inactive;
    final defaultActiveDotColor = effect.activeDotColor ?? indicatorColors.active;

    var dotOffset = -effect.spacing / 2;

    final paint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    for (var i = 0; i < count; i++) {
      dotOffset += effect.spacing + effect.dotWidth;
      final xPos = dotOffset - effect.dotWidth / 2;
      final yPos = size.height / 2;

      var color = defaultDotColor;

      if (i <= current) {
        color = defaultActiveDotColor;
      } else if (i == current + 1) {
        color = Color.lerp(defaultDotColor, defaultActiveDotColor, progress)!;
      } else {
        color = defaultDotColor;
      }

      paint.color = color;

      final rRect = RRect.fromLTRBR(
        xPos - effect.dotWidth / 2,
        yPos - effect.dotHeight / 2,
        xPos + effect.dotWidth / 2,
        yPos + effect.dotHeight / 2,
        Radius.circular(effect.radius),
      );

      canvas.drawRRect(rRect, paint);
    }
  }
}
