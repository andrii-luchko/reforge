import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';

class LvlWidget extends StatelessWidget {
  const LvlWidget({
    required this.lvl,
    super.key,
  });

  final int lvl;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return ClipPath(
      clipper: _LVLClipper(),
      child: Container(
        padding: const .only(left: 8, right: 8, bottom: 32, top: 24),
        decoration: BoxDecoration(color: appTheme.orange500),
        child: Text(
          style: TextStyle(
            color: context.appTheme.beige100,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.mechsuit,
            height: 23 / 12,
          ),
          'LV.\n$lvl',
        ),
      ),
    );
  }
}

class _LVLClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    const topRadius = 4.0;

    const shoulderRadius = 12.0;

    const tipRadius = 4.0;

    final breakY = h * 0.7;
    const tipInsetX = 5.0;

    final path = Path()
      ..moveTo(0, topRadius)
      ..arcToPoint(
        const Offset(topRadius, 0),
        radius: const Radius.circular(topRadius),
      )
      ..lineTo(w - topRadius, 0)
      ..arcToPoint(
        Offset(w, topRadius),
        radius: const Radius.circular(topRadius),
      )
      ..lineTo(w, breakY - shoulderRadius)
      ..arcToPoint(
        Offset(w - shoulderRadius * 0.6, breakY + shoulderRadius * 0.8),
        radius: const Radius.circular(shoulderRadius),
      )
      ..lineTo(tipInsetX + tipRadius, h - tipRadius * 0.5)
      ..arcToPoint(
        Offset(0, h - tipRadius * 1.5),
        radius: const Radius.circular(tipRadius),
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
