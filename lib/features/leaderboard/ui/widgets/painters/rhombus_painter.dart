import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RhombusPainter extends CustomPainter {
  RhombusPainter({
    this.backgroundColor = const Color(0xff180D05),

    this.radialGradientColors,

    this.strokeGradientColors,

    this.strokeWidth = 1.0,
    this.shadows,
  });

  final Color backgroundColor;
  final List<Color>? radialGradientColors;
  final List<Color>? strokeGradientColors;
  final double strokeWidth;
  final List<BoxShadow>? shadows;
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 108.0;
    final sy = size.height / 34.0;
    final scaleMatrix = Matrix4.diagonal3Values(sx, sy, 1);

    final path = Path()
      ..moveTo(17.9195, 0.84071)
      ..cubicTo(18.6212, 0.29579, 19.4843, 0, 20.3728, 0)
      ..lineTo(87.5837, 0)
      ..cubicTo(88.4722, 0, 89.3354, 0.29579, 90.0371, 0.84071)
      ..lineTo(106.41, 13.555)
      ..cubicTo(108.472, 15.1564, 108.472, 18.2722, 106.41, 19.8736)
      ..lineTo(90.0371, 32.5879)
      ..cubicTo(89.3354, 33.1328, 88.4722, 33.4286, 87.5837, 33.4286)
      ..lineTo(20.3728, 33.4286)
      ..cubicTo(19.4843, 33.4286, 18.6212, 33.1328, 17.9195, 32.5879)
      ..lineTo(1.54664, 19.8736)
      ..cubicTo(-0.515568, 18.2722, -0.515566, 15.1564, 1.54664, 13.555)
      ..lineTo(17.9195, 0.84071)
      ..close();

    final scaledPath = path.transform(scaleMatrix.storage);

    final solidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    canvas.drawPath(scaledPath, solidPaint);

    final radialMatrix = Matrix4(
      -107.792,
      -32.7671,
      0,
      0,
      110.764,
      -28.452,
      0,
      0,
      0,
      0,
      1,
      0,
      105.27,
      32.7671,
      0,
      1,
    );

    final scaledRadialMatrix = scaleMatrix.multiplied(radialMatrix);
    if (shadows != null) {
      for (final shadow in shadows!) {
        canvas.save();

        final shadowPadding = (shadow.blurRadius * 2) + 50.0;
        final rect = Rect.fromLTRB(
          -shadowPadding,
          -shadowPadding,
          size.width + shadowPadding,
          size.height + shadowPadding,
        );

        final clipPath = Path()
          ..addRect(rect)
          ..addPath(scaledPath, Offset.zero)
          ..fillType = PathFillType.evenOdd;

        canvas.clipPath(clipPath);

        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);

        final shadowPath = scaledPath.shift(shadow.offset);
        canvas
          ..drawPath(shadowPath, shadowPaint)
          ..restore();
      }
    }

    final radialColors =
        radialGradientColors ?? [const Color(0xff4A2105).withValues(alpha: 0), const Color(0xff4A2105)];

    final radialPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        radialColors,
        [0.53, 1.0],
        TileMode.clamp,
        scaledRadialMatrix.storage,
      );

    canvas.drawPath(scaledPath, radialPaint);

    final strokeColors =
        strokeGradientColors ??
        [const Color(0xffECE7DC).withValues(alpha: 0.6), const Color(0xffECE7DC).withValues(alpha: 0)];

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = ui.Gradient.linear(
        const Offset(11.3717, 0),
        const Offset(95.5656, 53.8511),
        strokeColors,
        [0.0, 1.0],
        TileMode.clamp,
        scaleMatrix.storage,
      );

    canvas.drawPath(scaledPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant RhombusPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radialGradientColors != radialGradientColors ||
        oldDelegate.strokeGradientColors != strokeGradientColors ||
        oldDelegate.shadows != shadows;
  }
}
