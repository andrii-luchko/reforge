import 'package:flutter/material.dart';
import 'package:reforge/features/training_session/data/models/tier.dart';
import 'package:reforge/features/training_session/ui/widgets/tier/tier_description.dart';
import 'package:reforge/features/training_session/ui/widgets/tier/tiers_selection_field.dart';

class TierSection extends StatelessWidget {
  const TierSection({
    required this.controller,

    required this.onTearChanged,
    required this.tiers,
    super.key,
    this.initialTier,
  });

  final TextEditingController controller;
  final List<Tier> tiers;
  final Tier? initialTier;
  final ValueChanged<Tier> onTearChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        TierSelectionField(
          controller: controller,
          initialValue: initialTier,
          tiersList: tiers,
          onChanged: onTearChanged,
        ),
        if (initialTier != null)
          TierDescription(
            description: initialTier!.description,
          ),
      ],
    );
  }
}
