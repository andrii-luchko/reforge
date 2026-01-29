import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/second_formatter.dart';
import 'package:reforge/core/timer/ui/smooth_timer_text.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    required this.progress,
    required this.mainTime,
    required this.totalTime,
    super.key,
  });

  final double progress;
  final int mainTime;
  final int totalTime;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final hasHours = mainTime.abs() >= 3600;
    final timeStyle = hasHours
        ? subheadH5Medium.copyWith(color: appTheme.beige100)
        : subheadH2Medium.copyWith(color: appTheme.beige100);

    final digitWidth = hasHours ? 10.0 : 13.5;

    return TweenAnimationBuilder<double>(
      duration: Durations.long1,
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: 0, end: progress),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _TimerPainter(value),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SmoothTimerText(
                    formatSeconds(mainTime),
                    style: timeStyle,
                    digitWidth: digitWidth,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatSeconds(totalTime),
                style: subheadH8Semibold.copyWith(color: appTheme.beige600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas
      ..drawCircle(center, radius + (strokeWidth / 2), borderPaint)
      ..drawCircle(center, radius - (strokeWidth / 2), borderPaint);

    const gradient = RadialGradient(
      center: Alignment(1.89, -0.01),
      radius: 1.34,
      colors: [
        Color(0xFFF6AA87),
        Color(0xFF9B390D),
      ],
      transform: GradientRotation(-pi / 2),
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
