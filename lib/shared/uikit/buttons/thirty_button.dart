import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';

class ThirtyButton extends StatelessWidget {
  const ThirtyButton({
    required this.text,
    this.style,
    this.onPressed,
    this.iconAsset,
    this.iconSize = 24,
    this.textDecoration = TextDecoration.underline,
    this.padding,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextDecoration? textDecoration;

  final double iconSize;
  final String? iconAsset;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isActive = onPressed != null;
    final color = isActive ? context.appTheme.beige100 : context.appTheme.beige700;

    final textStyle = style ?? subheadH5Medium;

    final icon = iconAsset == null
        ? null
        : AppSvgIcon(
            asset: iconAsset!,
            color: color,
          );

    return TextButton.icon(
      style: TextButton.styleFrom(
        overlayColor: context.appTheme.beige50,
        padding: padding,
      ),
      onPressed: onPressed,
      icon: icon,
      label: Text(
        text,
        style: textStyle.copyWith(
          decoration: textDecoration,
          decorationColor: color,
          color: color,
        ),
      ),
    );
  }
}
