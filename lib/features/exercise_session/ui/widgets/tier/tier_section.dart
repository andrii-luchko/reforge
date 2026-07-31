import 'package:flutter/material.dart';
import 'package:reforge/features/exercise_session/ui/widgets/tier/tier_description.dart';
import 'package:reforge/features/exercise_session/ui/widgets/tier/tiers_selection_field.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';

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
      spacing: 12,
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
