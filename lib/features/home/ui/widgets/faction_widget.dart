import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class FactionWidget extends StatelessWidget {
  const FactionWidget({
    required this.faction,
    super.key,
  });
  final String faction;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SharpFactionClipper(),
      child: Container(
        color: context.appTheme.beige400,
        padding: const .only(top: 4, bottom: 6.5, left: 5, right: 48),
        child: Text(
          faction,

          textAlign: .center,

          style: avatarBaseStyle.copyWith(color: context.appTheme.beige900),
        ),
      ),
    );
  }
}

class SharpFactionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final cutPointX = w * 0.801;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(cutPointX, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
