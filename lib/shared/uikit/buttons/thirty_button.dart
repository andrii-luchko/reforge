import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class ThirtyButton extends StatelessWidget {
  const ThirtyButton({
    required this.text,
    this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(overlayColor: context.appTheme.beige50),
      onPressed: onPressed,
      child: Text(
        text,
        style: subheadH5Medium.copyWith(decoration: TextDecoration.underline, color: context.appTheme.beige100),
      ),
    );
  }
}
