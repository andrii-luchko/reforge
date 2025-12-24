import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/faction_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SelectSecondFactionStep extends StatefulWidget {
  const SelectSecondFactionStep({super.key});

  @override
  State<SelectSecondFactionStep> createState() => _SelectSecondFactionStepState();
}

class _SelectSecondFactionStepState extends State<SelectSecondFactionStep> {
  Faction? _selectedFaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.second_faction.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 16),
        Text(
          t.quiz.steps.second_faction.subtitle,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
        const SizedBox(height: 32),
        FactionSelector(
          selectedFaction: _selectedFaction,
          onFactionChanged: (faction) {
            setState(() {
              _selectedFaction = faction;
            });
          },
        ),
      ],
    );
  }
}
