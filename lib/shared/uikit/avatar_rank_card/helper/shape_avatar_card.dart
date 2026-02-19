import 'dart:ui';

Path geAvatarSharpPath(Size size) {
  final path = Path();
  final w = size.width;
  final h = size.height;

  final cutSize = w / 12;
  final sideIndent = w / 7;
  final stepHeight = h / 3;

  path
    ..moveTo(0, 0)
    ..lineTo(w - sideIndent - cutSize, 0)
    ..lineTo(w - sideIndent, cutSize)
    ..lineTo(w - sideIndent, h - stepHeight)
    ..lineTo(w, h - stepHeight)
    ..lineTo(w, h)
    ..lineTo(0, h)
    ..close();

  return path;
}
