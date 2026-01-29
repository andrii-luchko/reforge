import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class WorkoutLabeledField extends StatelessWidget {
  const WorkoutLabeledField({required this.label, required this.field, super.key});

  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      spacing: 16,
      children: [
        Text(
          label,
          style: subheadH3Medium.copyWith(color: appTheme.beige100),
        ),
        field,
      ],
    );
  }
}
