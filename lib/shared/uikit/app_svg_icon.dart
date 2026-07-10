import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon({
    required this.asset,
    this.color,
    this.size = 24,
    super.key,
  });

  final double? size;
  final String asset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null ? null : ColorFilter.mode(color!, .srcIn),
    );
  }
}
