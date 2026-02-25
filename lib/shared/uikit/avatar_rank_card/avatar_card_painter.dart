import 'package:flutter/material.dart';
import 'package:reforge/shared/uikit/avatar_rank_card/helper/shape_avatar_card.dart';

class AvatarCardPainter extends CustomPainter {
  AvatarCardPainter({
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = geAvatarSharpPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AvatarCardPainter oldDelegate) => false;
}
