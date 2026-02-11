import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class XpTile extends StatelessWidget {
  const XpTile({required this.currentXp, required this.totalXp, super.key});

  final int currentXp;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final progress = currentXp / totalXp;
    final percentage = (progress * 100).toInt();
    final appTheme = context.appTheme;

    final currentXpFormatted = XpFormatter.compact(currentXp);
    final totalXpFormatted = XpFormatter.compact(totalXp);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                context.t.home.xp_earned,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),
              Text('$percentage%', style: subheadH3Medium.copyWith(color: appTheme.beige600)),
            ],
          ),
          const SizedBox(height: 20),

          Skeleton.leaf(child: HorizontalXPBar(progress: progress)),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(currentXpFormatted, style: subheadH5Medium.copyWith(color: appTheme.beige100)),
              Text(totalXpFormatted, style: subheadH5Medium.copyWith(color: appTheme.beige100)),
            ],
          ),
        ],
      ),
    );
  }
}

class HorizontalXPBar extends StatelessWidget {
  const HorizontalXPBar({required this.progress, super.key});

  final double progress;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(50);
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: [
            appTheme.beige100.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              appTheme.beige100,
              Colors.transparent,
            ],
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: appTheme.strokeCard,
          ),
          borderRadius: .circular(50),
        ),

        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: TweenAnimationBuilder<double>(
              duration: Durations.extralong1,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, child) {
                return CustomPaint(
                  painter: XpBarPainter(gradient: appTheme.gradientXpBar, progress: value),
                  size: const Size.fromHeight(25),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class XpBarPainter extends CustomPainter {
  XpBarPainter({
    required this.gradient,
    required this.progress,
  });
  final Gradient gradient;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    canvas.save();

    final radiusValue = size.height / 2;

    final currentWidth = size.width * progress;

    final progressRect = Rect.fromLTWH(0, 0, currentWidth, size.height);

    final progressRRect = RRect.fromRectAndRadius(
      progressRect,
      Radius.circular(radiusValue),
    );

    canvas.clipRRect(progressRRect);

    final stripePaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    const stripeWidth = 12.0;
    const gap = 8.0;

    final tiltOffset = size.height / math.tan(math.pi / 4);

    final startX = -tiltOffset - stripeWidth;
    final endX = size.width + stripeWidth;

    for (var x = startX; x < endX; x += stripeWidth + gap) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + tiltOffset, 0)
        ..lineTo(x + tiltOffset, 0)
        ..close();

      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant XpBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
