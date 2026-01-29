import 'package:flutter/material.dart';

class NotchedContainer extends StatelessWidget {
  const NotchedContainer({
    super.key,
    this.child,
    this.backgroundGradient,
    this.borderColor = Colors.black,
    this.borderWidth = 1.5,
    this.cornerRadius = 18.0,
    this.notchWidth = 140.0,
    this.notchDepth = 20.0,
    this.notchCornerRadius = 1.0,
    this.borderGradient,
    this.notchBottomWidthRatio = 0.6,
  });

  final Widget? child;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;
  final double notchCornerRadius;
  final Gradient? borderGradient;
  final Gradient? backgroundGradient;
  final double notchBottomWidthRatio;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotchedBorderPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        cornerRadius: cornerRadius,
        notchWidth: notchWidth,
        notchDepth: notchDepth,
        notchCornerRadius: notchCornerRadius,
        borderGradient: borderGradient,
        notchBottomWidthRatio: notchBottomWidthRatio,
      ),
      child: ClipPath(
        clipper: _NotchedClipper(
          cornerRadius: cornerRadius,
          notchWidth: notchWidth,
          notchDepth: notchDepth,
          notchCornerRadius: notchCornerRadius,
          notchBottomWidthRatio: notchBottomWidthRatio,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NotchedBorderPainter extends CustomPainter {
  _NotchedBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.cornerRadius,
    required this.notchWidth,
    required this.notchDepth,
    required this.notchCornerRadius,
    required this.notchBottomWidthRatio,
    this.borderGradient,
  });

  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;
  final double notchCornerRadius;
  final Gradient? borderGradient;
  final double notchBottomWidthRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createTopBorderPath(size);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth;

    if (borderGradient != null) {
      paint.shader = borderGradient!.createShader(rect);
    } else {
      paint.color = borderColor;
    }

    canvas.drawPath(path, paint);
  }

  Path _createTopBorderPath(Size size) {
    final path = Path();
    final w = size.width;
    final centerX = w / 2;

    path
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(centerX - (notchWidth / 2) - notchCornerRadius, 0)
      ..quadraticBezierTo(
        centerX - (notchWidth / 2),
        0,
        centerX - (notchWidth / 2) + notchCornerRadius,
        notchCornerRadius,
      );

    final topHalfWidth = notchWidth / 2;
    final bottomHalfWidth = topHalfWidth * notchBottomWidthRatio;

    path
      ..lineTo(
        centerX - bottomHalfWidth - notchCornerRadius,
        notchDepth - notchCornerRadius,
      )
      ..quadraticBezierTo(
        centerX - bottomHalfWidth,
        notchDepth,
        centerX - bottomHalfWidth + notchCornerRadius,
        notchDepth,
      )
      ..lineTo(centerX + bottomHalfWidth - notchCornerRadius, notchDepth)
      ..quadraticBezierTo(
        centerX + bottomHalfWidth,
        notchDepth,
        centerX + bottomHalfWidth + notchCornerRadius,
        notchDepth - notchCornerRadius,
      )
      ..lineTo(
        centerX + (notchWidth / 2) - notchCornerRadius,
        notchCornerRadius,
      )
      ..quadraticBezierTo(
        centerX + (notchWidth / 2),
        0,
        centerX + (notchWidth / 2) + notchCornerRadius,
        0,
      )
      ..lineTo(w - cornerRadius, 0)
      ..quadraticBezierTo(w, 0, w, cornerRadius);

    return path;
  }

  @override
  bool shouldRepaint(_NotchedBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.notchWidth != notchWidth ||
        oldDelegate.notchDepth != notchDepth ||
        oldDelegate.notchCornerRadius != notchCornerRadius ||
        oldDelegate.borderGradient != borderGradient ||
        oldDelegate.notchBottomWidthRatio != notchBottomWidthRatio;
  }
}

class _NotchedClipper extends CustomClipper<Path> {
  _NotchedClipper({
    required this.cornerRadius,
    required this.notchWidth,
    required this.notchDepth,
    required this.notchCornerRadius,
    required this.notchBottomWidthRatio,
  });

  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;
  final double notchCornerRadius;
  final double notchBottomWidthRatio;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    path
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(centerX - (notchWidth / 2) - notchCornerRadius, 0)
      ..quadraticBezierTo(
        centerX - (notchWidth / 2),
        0,
        centerX - (notchWidth / 2) + notchCornerRadius,
        notchCornerRadius,
      );

    final topHalfWidth = notchWidth / 2;
    final bottomHalfWidth = topHalfWidth * notchBottomWidthRatio;

    path
      ..lineTo(
        centerX - bottomHalfWidth - notchCornerRadius,
        notchDepth - notchCornerRadius,
      )
      ..quadraticBezierTo(
        centerX - bottomHalfWidth,
        notchDepth,
        centerX - bottomHalfWidth + notchCornerRadius,
        notchDepth,
      )
      ..lineTo(centerX + bottomHalfWidth - notchCornerRadius, notchDepth)
      ..quadraticBezierTo(
        centerX + bottomHalfWidth,
        notchDepth,
        centerX + bottomHalfWidth + notchCornerRadius,
        notchDepth - notchCornerRadius,
      )
      ..lineTo(
        centerX + (notchWidth / 2) - notchCornerRadius,
        notchCornerRadius,
      )
      ..quadraticBezierTo(
        centerX + (notchWidth / 2),
        0,
        centerX + (notchWidth / 2) + notchCornerRadius,
        0,
      )
      ..lineTo(w - cornerRadius, 0)
      ..quadraticBezierTo(w, 0, w, cornerRadius)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_NotchedClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchWidth != notchWidth ||
        oldClipper.notchDepth != notchDepth ||
        oldClipper.notchCornerRadius != notchCornerRadius ||
        oldClipper.notchBottomWidthRatio != notchBottomWidthRatio;
  }
}
