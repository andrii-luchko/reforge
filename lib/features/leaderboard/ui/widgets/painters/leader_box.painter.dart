import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class LeaderBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 358.0;
    final sy = size.height / 266.0;

    final matrix = Matrix4.diagonal3Values(sx, sy, 1);

    final path = Path()
      ..moveTo(8, 0.5)
      ..lineTo(100, 0.5)
      ..cubicTo(104.142, 0.5, 107.5, 3.85786, 107.5, 8)
      ..lineTo(107.5, 50.4375)
      ..cubicTo(107.5, 53.4419, 109.086, 56.2231, 111.672, 57.7529)
      ..lineTo(174.672, 95.0205)
      ..cubicTo(177.341, 96.5994, 180.659, 96.5994, 183.328, 95.0205)
      ..lineTo(246.328, 57.7529)
      ..cubicTo(248.914, 56.2231, 250.5, 53.4419, 250.5, 50.4375)
      ..lineTo(250.5, 8)
      ..cubicTo(250.5, 3.85786, 253.858, 0.5, 258, 0.5)
      ..lineTo(350, 0.5)
      ..cubicTo(354.142, 0.5, 357.5, 3.85786, 357.5, 8)
      ..lineTo(357.5, 258)
      ..cubicTo(357.5, 262.142, 354.142, 265.5, 350, 265.5)
      ..lineTo(261.5, 265.5)
      ..cubicTo(257.358, 265.5, 254, 262.142, 254, 258)
      ..lineTo(254, 215.9)
      ..cubicTo(254, 212.705, 252.208, 209.78, 249.362, 208.328)
      ..lineTo(182.85, 174.402)
      ..cubicTo(180.431, 173.169, 177.568, 173.165, 175.146, 174.392)
      ..lineTo(108.158, 208.333)
      ..cubicTo(105.301, 209.781, 103.5, 212.712, 103.5, 215.915)
      ..lineTo(103.5, 258)
      ..cubicTo(103.5, 262.142, 100.142, 265.5, 96, 265.5)
      ..lineTo(8, 265.5)
      ..cubicTo(3.85786, 265.5, 0.5, 262.142, 0.5, 258)
      ..lineTo(0.5, 8)
      ..cubicTo(0.5, 3.85786, 3.85786, 0.5, 8, 0.5)
      ..close();

    final scaledPath = path.transform(matrix.storage);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff180D05);

    canvas.drawPath(scaledPath, fillPaint);

    final grad1Matrix = Matrix4.identity()
      ..setTranslationRaw(179, 118.5, 0)
      ..rotateZ(176.125 * math.pi / 180)
      ..multiply(Matrix4.diagonal3Values(125.788, 169.293, 1));

    final stroke1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * math.min(sx, sy)
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        [const Color(0xffECE7DC), const Color(0xffECE7DC).withValues(alpha: 0)],
        [0.0, 1.0],
        TileMode.clamp,
        grad1Matrix.storage,
      )
      ..color = const Color(0xff000000).withValues(alpha: 0.8);

    canvas.drawPath(scaledPath, stroke1Paint);

    final grad2Matrix = Matrix4.identity()
      ..setTranslationRaw(179, 133, 0)
      ..rotateZ(90 * math.pi / 180)
      ..multiply(Matrix4.diagonal3Values(133, 179, 1));

    final stroke2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * math.min(sx, sy)
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        [const Color(0xff2B221A).withValues(alpha: 0), const Color(0xff2B221A)],
        [0.0, 1.0],
        TileMode.clamp,
        grad2Matrix.storage,
      );

    canvas.drawPath(scaledPath, stroke2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
