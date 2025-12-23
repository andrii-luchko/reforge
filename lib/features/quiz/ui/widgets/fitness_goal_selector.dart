import 'package:flutter/material.dart';

import 'package:reforge/features/quiz/domain/main_goal.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class FitnessGoalSelector extends StatelessWidget {
  const FitnessGoalSelector({
    required this.selectedGoal,
    required this.onGoalChanged,
    super.key,
  });

  final MainGoal? selectedGoal;
  final ValueChanged<MainGoal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: MainGoal.values.map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: goal.title(t),
            description: goal.description(t),
            isSelected: selectedGoal == goal,
            onTap: () => onGoalChanged(goal),
          ),
        );
      }).toList(),
    );
  }
}
