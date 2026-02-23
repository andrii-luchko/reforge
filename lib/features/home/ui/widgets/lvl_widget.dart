import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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
        padding: const .only(left: 8, right: 8, bottom: 48, top: 21),
        decoration: BoxDecoration(color: appTheme.orange500),
        child: Text(
          textAlign: .center,
          style: avatarBaseStyle.copyWith(color: context.appTheme.beige100),
          '${t.home.lvPrefix}\n$lvl',
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
    const r = 2.0;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h * 0.678)
      ..lineTo(w * 0.075, h - (h * 0.006))
      ..lineTo(0, h - r)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
