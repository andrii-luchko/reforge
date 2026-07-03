import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.iconAsset,
    this.onPressed,
    this.width = 56,
    this.height = 56,
    this.iconSize = 24,
    super.key,
  }) : iconData = null,
       isAsset = true;

  const AppIconButton.icon({
    required IconData this.iconData,
    this.onPressed,
    this.width = 56,
    this.height = 56,
    this.iconSize = 24,
    super.key,
  }) : iconAsset = '',
       isAsset = false;

  final String iconAsset;
  final IconData? iconData;
  final bool isAsset;
  final double width;
  final double height;
  final double? iconSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(50);

    return PressableAnimation(
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
          backgroundColor: appTheme.beige50.withValues(alpha: 0.2),
          borderColor: appTheme.beige100.withValues(alpha: 0.1),
          child: Center(
            child: _buildIcon(appTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(AppTheme appTheme) {
    if (isAsset) {
      return SvgPicture.asset(
        iconAsset,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          appTheme.beige400,
          BlendMode.srcIn,
        ),
      );
    } else {
      return Icon(
        iconData,
        size: iconSize,
        color: appTheme.beige400,
      );
    }
  }
}
