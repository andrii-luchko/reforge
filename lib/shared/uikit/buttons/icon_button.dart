import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.iconAsset,
    this.onPressed,
    this.width = 56,
    this.height = 56,
    this.iconSize,

    super.key,
  });

  final String iconAsset;
  final double width;
  final double height;
  final double? iconSize;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final borderRadius = BorderRadius.circular(50);

    return GestureDetector(
      onTap: onPressed,
      child: BlurContainer(
        borderRadius: borderRadius,
        child: BaseGlassContainer(
          borderRadius: borderRadius,
          width: width,
          height: height,
          glassEffectGradientAlignmentBegin: .topLeft,
          glassEffectGradientAlignmentEnd: .bottomRight,

          borderGradientColors: [
            appTheme.beige100,
            Colors.transparent,
            Colors.transparent,
            appTheme.beige100,
          ],

          surfaceGradientColors: const [
            Colors.transparent,
            Colors.transparent,
          ],

          backgroundColor: appTheme.beige50,

          borderColor: appTheme.beige100.withValues(alpha: 0.1),

          child: Material(
            borderRadius: borderRadius,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              splashFactory: InkSparkle.splashFactory,
              splashColor: appTheme.beige100.withValues(alpha: 0.1),
              highlightColor: appTheme.beige100.withValues(alpha: 0.01),
              onTap: onPressed,
              child: Padding(
                padding: const .symmetric(vertical: 16),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(
                      appTheme.beige100,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
