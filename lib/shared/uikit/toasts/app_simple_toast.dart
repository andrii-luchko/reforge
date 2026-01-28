import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppSimpleToast extends StatelessWidget {
  const AppSimpleToast({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: appTheme.orange500,
      ),
      child: Text(
        text,
        style: subheadH3Medium.copyWith(color: appTheme.beige100),
      ),
    );
  }
}
