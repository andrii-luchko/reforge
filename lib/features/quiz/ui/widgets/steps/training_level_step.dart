import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/training_level.dart';
import 'package:reforge/features/quiz/ui/widgets/training_level_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class TrainingLevelStep extends StatefulWidget {
  const TrainingLevelStep({super.key});

  @override
  State<TrainingLevelStep> createState() => _TrainingLevelStepState();
}

class _TrainingLevelStepState extends State<TrainingLevelStep> {
  TrainingLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.training_level.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        TrainingLevelSelector(
          selectedLevel: _selectedLevel,
          onLevelChanged: (level) {
            setState(() {
              _selectedLevel = level;
            });
          },
        ),
      ],
    );
  }
}
