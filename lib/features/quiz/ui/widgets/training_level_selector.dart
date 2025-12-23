import 'package:flutter/material.dart';

import 'package:reforge/features/quiz/domain/training_level.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class TrainingLevelSelector extends StatelessWidget {
  const TrainingLevelSelector({
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final TrainingLevel? selectedLevel;
  final ValueChanged<TrainingLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: TrainingLevel.values.map((level) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: level.title(t),
            description: level.description(t),
            isSelected: selectedLevel == level,
            onTap: () => onLevelChanged(level),
          ),
        );
      }).toList(),
    );
  }
}
