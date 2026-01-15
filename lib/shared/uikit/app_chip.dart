import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppChip extends StatelessWidget {
  const AppChip({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(50);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: appTheme.beige900,
        border: GradientBoxBorder(gradient: appTheme.strokeTag, width: 1.5),
      ),

      child: Center(
        child: Text(label, style: subheadH5Medium.copyWith(color: appTheme.beige100)),
      ),
    );
  }
}
