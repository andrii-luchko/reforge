import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';

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
        padding: const .only(top: 4, bottom: 6.5, left: 5, right: 29),
        child: Text(
          faction,

          style: TextStyle(
            color: context.appTheme.beige900,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.mechsuit,
            height: 23 / 12,
          ),
        ),
      ),
    );
  }
}

class SharpFactionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
