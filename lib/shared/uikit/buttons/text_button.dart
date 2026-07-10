import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.onPressed,
    required this.text,
    required this.assetPath,
    this.style,
    this.themeColor,
    this.iconSize = 18,
    this.spacing = 6,
    this.padding = .zero,
    this.decoration,
    super.key,
  });

  final VoidCallback? onPressed;
  final String text;
  final TextStyle? style;
  final String assetPath;
  final Color? themeColor;

  final double iconSize;
  final double spacing;

  final EdgeInsets padding;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final resolvedThemeColor = themeColor ?? context.appTheme.beige100;
    final style = this.style ?? subheadH5Medium;

    return PressableAnimation(
      scaleAmount: 0.99,
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: [
            AppSvgIcon(
              asset: assetPath,
              size: iconSize,
              color: resolvedThemeColor,
            ),
            Text(
              text,
              style: style.copyWith(color: resolvedThemeColor),
            ),
          ],
        ),
      ),
    );
  }
}
