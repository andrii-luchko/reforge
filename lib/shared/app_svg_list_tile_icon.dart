import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';

class AppSvgListTileIcon extends StatelessWidget {
  const AppSvgListTileIcon({required this.asset, super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: .circle,
        color: appTheme.beige900,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: .topLeft,
            end: .bottomRight,
            colors: [
              appTheme.beige100.withValues(alpha: 0.4),
              appTheme.beige100.withValues(alpha: 0),
            ],
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
            height: 24,
            width: 24,
            asset,

            colorFilter: ColorFilter.mode(appTheme.beige700, .srcIn),
          ),
        ),
      ),
    );
  }
}
