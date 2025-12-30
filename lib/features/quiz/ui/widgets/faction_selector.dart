import 'package:flutter/material.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class FactionSelector extends StatelessWidget {
  const FactionSelector({
    required this.selectedFaction,
    required this.onFactionChanged,
    super.key,
  });

  final Faction? selectedFaction;
  final ValueChanged<Faction> onFactionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Faction.values.map((faction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: faction.title(t),
            isSelected: selectedFaction == faction,
            onTap: () => onFactionChanged(faction),
          ),
        );
      }).toList(),
    );
  }
}
