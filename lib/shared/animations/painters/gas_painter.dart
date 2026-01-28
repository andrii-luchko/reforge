import 'package:flutter/material.dart';

class GasWidget extends StatelessWidget {
  const GasWidget({
    required this.color,
    this.blurRadius = 60.0,
    this.size = const Size(300, 300),
    super.key,
  });

  final Color color;
  final double blurRadius;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: CustomPaint(
        painter: _GasPainter(color: color, blurRadius: blurRadius),
      ),
    );
  }
}

class _GasPainter extends CustomPainter {
  _GasPainter({required this.color, required this.blurRadius});

  final Color color;
  final double blurRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final radius = size.shortestSide * 0.3;

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas
      ..drawCircle(center, radius, paint)
      ..drawCircle(center.translate(radius * 0.4, 0), radius * 0.8, paint)
      ..drawCircle(center.translate(-radius * 0.4, -radius * 0.2), radius * 0.9, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
