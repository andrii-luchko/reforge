import 'dart:async';

import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class XpIndicatorWidget extends StatefulWidget {
  const XpIndicatorWidget({required this.xp, required this.xpProgress, required this.height, super.key});

  final double height;
  final int xp;
  final double xpProgress;

  @override
  State<XpIndicatorWidget> createState() => _XpIndicatorWidgetState();
}

class _XpIndicatorWidgetState extends State<XpIndicatorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        spacing: 8,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              '${widget.xp}xp',
              style: subheadH5Medium.copyWith(
                color: context.appTheme.beige100,
                fontSize: 13.2,
                height: 1.3,
                fontVariations: <FontVariation>[const FontVariation('wght', 600)],
              ),
            ),
          ),

          XpBarIndicator(
            height: widget.height,
            progress: widget.xpProgress,
          ),
        ],
      ),
    );
  }
}

class XpBarIndicator extends StatelessWidget {
  const XpBarIndicator({
    required this.progress,
    super.key,
    this.width = 22,
    this.height = 200,
    this.color = const Color(0xFF8B3A15),
  });

  final double progress;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TweenAnimationBuilder<double>(
        duration: Durations.extralong1,
        tween: Tween<double>(begin: 0, end: progress),
        builder: (context, progress, child) {
          return CustomPaint(
            painter: _XpBarPainter(
              progress: progress,
              barColor: color,
              borderColor: context.appTheme.beige100,
            ),
          );
        },
      ),
    );
  }
}

class _XpBarPainter extends CustomPainter {
  _XpBarPainter({
    required this.progress,
    required this.barColor,
    required this.borderColor,
  });

  final double progress;
  final Color barColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const slopeFactor = 1.2;
    const padding = 3.0;

    final cutHeight = size.width * slopeFactor;

    final outlinePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, cutHeight)
      ..lineTo(size.width, size.height)
      ..close();

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawPath(outlinePath, borderPaint)
      ..save();

    final innerPath = Path()
      ..moveTo(padding, size.height - padding)
      ..lineTo(padding, padding + padding)
      ..lineTo(size.width - padding, cutHeight + padding)
      ..lineTo(size.width - padding, size.height - padding)
      ..close();

    canvas.clipPath(innerPath);

    final currentFillHeight = size.height * progress;
    final topCoord = size.height - currentFillHeight;

    canvas.clipRect(Rect.fromLTRB(0, topCoord, size.width, size.height));

    final stripePaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    const stripeHeight = 10.0;
    const gap = 4.0;
    final stripeDrop = size.width * slopeFactor;

    for (var i = -size.width; i < size.height; i += stripeHeight + gap) {
      final stripePath = Path()
        ..moveTo(0, i)
        ..lineTo(size.width, i + stripeDrop)
        ..lineTo(size.width, i + stripeDrop + stripeHeight)
        ..lineTo(0, i + stripeHeight)
        ..close();

      canvas.drawPath(stripePath, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _XpBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.barColor != barColor ||
        oldDelegate.borderColor != borderColor;
  }
}
