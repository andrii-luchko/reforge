import 'package:flutter/material.dart';

class LoreCard extends StatelessWidget {
  const LoreCard({
    required this.child,
    this.width = 363,
    this.height = 78,
    this.onTap,
    this.backgroundColor,
    this.fillGradient,
    this.strokeColor,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.cornerRadius = 13.5,
    super.key,
  });

  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  final Gradient? fillGradient;
  final Color? strokeColor;
  final Gradient? borderGradient;

  final double borderWidth;

  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(width, height),
        painter: _LoreCardPainter(
          strokeColor: strokeColor,
          backgroundColor: backgroundColor ?? const Color(0xFF180D05),
          fillGradient:
              fillGradient ??
              const LinearGradient(
                begin: Alignment(-0.53, -1),
                end: Alignment(0.96, 1),
                colors: [
                  Color(0x009D3C10),
                  Color(0x4D9D3C10),
                ],
                stops: [0.6, 1.0],
              ),
          borderGradient: borderGradient,
          borderWidth: borderWidth,

          cornerRadius: cornerRadius,
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}

Path _getCardPath(Size size) {
  final sx = size.width / 363.0;
  final sy = size.height / 78.0;

  final matrix = Matrix4.diagonal3Values(sx, sy, 1);

  final path = Path()
    ..moveTo(3.5, 64.5)
    ..lineTo(3.5, 13.5)
    ..cubicTo(3.5, 7.97715, 7.97715, 3.5, 13.5, 3.5)
    ..lineTo(314.077, 3.5)
    ..cubicTo(316.296, 3.5, 318.452, 4.23791, 320.205, 5.59756)
    ..lineTo(355.628, 33.0662)
    ..cubicTo(358.071, 34.9604, 359.5, 37.8776, 359.5, 40.9687)
    ..lineTo(359.5, 64.5)
    ..cubicTo(359.5, 70.0229, 355.023, 74.5, 349.5, 74.5)
    ..lineTo(13.5, 74.5)
    ..cubicTo(7.97715, 74.5, 3.5, 70.0229, 3.5, 64.5)
    ..close();

  return path.transform(matrix.storage);
}

class _LoreCardPainter extends CustomPainter {
  const _LoreCardPainter({
    required this.backgroundColor,
    required this.strokeColor,
    required this.cornerRadius,
    this.fillGradient,
    this.borderGradient,
    this.borderWidth = 1.0,
  });

  final Color backgroundColor;
  final Gradient? fillGradient;
  final Color? strokeColor;
  final Gradient? borderGradient;
  final double borderWidth;

  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final scaledPath = _getCardPath(size);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawPath(scaledPath, fillPaint);

    if (fillGradient != null) {
      final gradientPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = fillGradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(scaledPath, gradientPaint);
    }

    if (strokeColor != null) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = strokeColor!;
      canvas.drawPath(scaledPath, strokePaint);
    }

    if (borderGradient != null) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..shader = borderGradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(scaledPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoreCardPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.fillGradient != fillGradient ||
        oldDelegate.borderGradient != borderGradient ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

class LoreCardShimmer extends StatelessWidget {
  const LoreCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LoreCardClipper(),
      child: Container(
        height: 78,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}

class _LoreCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getCardPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
