import 'dart:math';
import 'dart:ui';
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
    double offset = 0.0,
    double dotWidth = 16.0,
    double dotHeight = 16.0,
    double spacing = 8.0,
    double radius = 16.0,
    Color? dotColor,
    Color? activeDotColor,
    double strokeWidth = 1.0,
    PaintingStyle paintStyle = PaintingStyle.fill,
  }) : super(
         dotWidth: dotWidth,
         dotHeight: dotHeight,
         spacing: spacing,
         radius: radius,
         strokeWidth: strokeWidth,
         paintStyle: paintStyle,
         dotColor: dotColor,
         activeDotColor: activeDotColor,
       );

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
    // Определяем текущий активный индекс (целая часть)
    final int current = offset.floor();

    // Определяем прогресс перехода к следующей точке (от 0.0 до 1.0)
    final double progress = offset - current;

    // Цвета по умолчанию или из темы
    final Color defaultDotColor = effect.dotColor ?? indicatorColors.inactive;
    final Color defaultActiveDotColor = effect.activeDotColor ?? indicatorColors.active;

    // Начальная позиция отрисовки с учетом ширины точки и отступа
    double dotOffset = -effect.spacing / 2;

    // Подготовка Paint объекта
    final Paint paint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    for (int i = 0; i < count; i++) {
      // Рассчитываем позицию точки
      // Логика взята из стандартных пейнтеров smooth_page_indicator
      dotOffset += effect.spacing + effect.dotWidth;
      final double xPos = dotOffset - effect.dotWidth / 2;
      final double yPos = size.height / 2;

      Color color = defaultDotColor;

      if (i <= current) {
        // 1. Прошедшие точки и текущая активная точка
        // Они всегда окрашены в активный цвет
        color = defaultActiveDotColor;
      } else if (i == current + 1) {
        // 2. Следующая точка (к которой мы свайпаем)
        // Она плавно переходит из dotColor в activeDotColor
        color = Color.lerp(defaultDotColor, defaultActiveDotColor, progress)!;
      } else {
        // 3. Будущие точки (дальше чем +1)
        // Остаются стандартного цвета
        color = defaultDotColor;
      }

      paint.color = color;

      // Рисуем RRect (закругленный прямоугольник/круг)
      final RRect rRect = RRect.fromLTRBR(
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
