import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/main_goal.dart';
import 'package:reforge/features/quiz/ui/widgets/fitness_goal_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class MainGoalStep extends StatefulWidget {
  const MainGoalStep({super.key});

  @override
  State<MainGoalStep> createState() => _MainGoalStepState();
}

class _MainGoalStepState extends State<MainGoalStep> {
  MainGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.main_goal.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        FitnessGoalSelector(
          selectedGoal: _selectedGoal,
          onGoalChanged: (goal) {
            setState(() {
              _selectedGoal = goal;
            });
          },
        ),
      ],
    );
  }
}
