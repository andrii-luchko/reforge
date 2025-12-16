import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class SplashAppLogo extends StatelessWidget {
  const SplashAppLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -3.23 * 3.14 / 180,
            child: const _BackgroundSquareContainer(),
          ),
          Transform.rotate(
            angle: 5.02 * 3.14 / 180,
            child: const _BackgroundSquareContainer(),
          ),
          BlurContainer(
            child: GlassContainer(
              child: Padding(
                padding: const .symmetric(horizontal: 16, vertical: 56),
                child: SvgPicture.asset(Assets.images.svg.logoAndName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundSquareContainer extends StatelessWidget {
  const _BackgroundSquareContainer();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: BoxBorder.all(
          color: appTheme.beige100.withValues(alpha: 0.1),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.beige900.withValues(alpha: 0.2),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
