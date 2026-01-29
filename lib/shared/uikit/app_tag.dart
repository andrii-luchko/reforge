import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppTag extends StatelessWidget {
  const AppTag({required this.text, this.textStyle, super.key});

  final String text;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final ts = textStyle ?? subheadH5Medium.copyWith(color: appTheme.beige100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: appTheme.orange500,
        border: GradientBoxBorder(gradient: appTheme.strokeTag),
      ),
      child: Text(
        text,
        style: ts,
      ),
    );
  }
}
