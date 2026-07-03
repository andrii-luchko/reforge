import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

    super.key,
  });

  final String text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final ts = textStyle ?? subheadH5Medium.copyWith(color: appTheme.beige100);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: appTheme.orange500,
        border: GradientBoxBorder(gradient: appTheme.strokeTag),

        boxShadow: [
          BoxShadow(
            color: appTheme.orange100.withValues(alpha: .4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: ts,
        ),
      ),
    );
  }
}
