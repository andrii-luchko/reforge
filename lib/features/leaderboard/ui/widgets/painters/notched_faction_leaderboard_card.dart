import 'package:flutter/widgets.dart';

class FactionPathFactory {
  static Path getNotchedPath(Size size) {
    const designWidth = 358.0;
    const designHeight = 156.0;

    final sx = size.width / designWidth;
    final sy = size.height / designHeight;
    final matrix = Matrix4.diagonal3Values(sx, sy, 1);

    final path = Path()
      ..moveTo(0, 20)
      ..cubicTo(0, 8.9543, 8.9543, 0, 20, 0)
      ..lineTo(338, 0)
      ..cubicTo(349.046, 0, 358, 8.95431, 358, 20)
      ..lineTo(358, 136)
      ..cubicTo(358, 147.046, 349.046, 156, 338, 156)
      ..lineTo(238.804, 156)
      ..cubicTo(234.701, 156, 230.697, 154.738, 227.335, 152.385)
      ..lineTo(217.665, 145.615)
      ..cubicTo(214.303, 143.262, 210.299, 142, 206.196, 142)
      ..lineTo(152.804, 142)
      ..cubicTo(148.701, 142, 144.697, 143.262, 141.335, 145.615)
      ..lineTo(131.665, 152.385)
      ..cubicTo(128.303, 154.738, 124.299, 156, 120.196, 156)
      ..lineTo(20, 156)
      ..cubicTo(8.9543, 156, 0, 147.046, 0, 136)
      ..close();

    return path.transform(matrix.storage);
  }
}

class FactionCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => FactionPathFactory.getNotchedPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class NotchedFactionLeaderboardCard extends CustomPainter {
  NotchedFactionLeaderboardCard({
    required this.strokeGradient,
    this.backgroundColor,

    this.fillGradient,
  });

  final Color? backgroundColor;
  final Gradient? fillGradient;
  final Gradient strokeGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final scaledPath = FactionPathFactory.getNotchedPath(size);
    final bounds = scaledPath.getBounds();

    if (backgroundColor != null) {
      final fillPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(scaledPath, fillPaint);
    }

    if (fillGradient != null) {
      final gradientPaint = Paint()
        ..shader = fillGradient!.createShader(bounds)
        ..style = PaintingStyle.fill;
      canvas.drawPath(scaledPath, gradientPaint);
    }

    final strokePaint = Paint()
      ..shader = strokeGradient.createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(scaledPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant NotchedFactionLeaderboardCard oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.fillGradient != fillGradient ||
        oldDelegate.strokeGradient != strokeGradient;
  }
}
