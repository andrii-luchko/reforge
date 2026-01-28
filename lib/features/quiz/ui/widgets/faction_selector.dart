import 'package:flutter/material.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class FactionSelector extends StatelessWidget {
  const FactionSelector({
    required this.selectedFactions,
    required this.onFactionToggled,
    this.mainFaction,
    super.key,
  });
  final Faction? mainFaction;
  final List<Faction> selectedFactions;
  final ValueChanged<Faction> onFactionToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Faction.values.map((faction) {
        if (faction == mainFaction) return const SizedBox();

        final isSelected = selectedFactions.contains(faction);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: faction.title(t),
            description: faction.description(t),
            isSelected: isSelected,
            onTap: () => onFactionToggled(faction),
          ),
        );
      }).toList(),
    );
  }
}
