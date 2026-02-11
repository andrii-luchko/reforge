import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

    return Skeleton.replace(
      width: width,
      height: height,
      replacement: Bone.circle(
        size: width,
      ),
      child: GestureDetector(
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
                child: Center(
                  child: _buildIcon(appTheme),
                ),
              ),
            ),
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
