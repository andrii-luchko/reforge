import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class ExerciseDescriptionSection extends StatelessWidget {
  const ExerciseDescriptionSection({required this.description, super.key});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.workout_instruction.aboutExercise,
          style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: subheadH6Regular.copyWith(color: context.appTheme.beige600),
        ),
      ],
    );
  }
}
