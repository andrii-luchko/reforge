import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_common/models/tier.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class TierSelectionField extends StatelessWidget {
  const TierSelectionField({
    required this.controller,
    required this.tiersList,
    required this.onChanged,
    this.initialValue,
    super.key,
  });
  final TextEditingController controller;
  final Tier? initialValue;
  final List<Tier> tiersList;
  final ValueChanged<Tier> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = subheadH3Medium.copyWith(color: context.appTheme.beige100);

    return LabeledAppTextField(
      label: t.workout.selectTier,
      field: PortalSelectField(
        controller: controller,
        hintText: t.workout.selectTier,
        heightFactor: 3,
        contentBuilder: (context, close) {
          final possibleTiers = tiersList
              .map(
                (tier) => Center(
                  child: Text(tier.title, style: style),
                ),
              )
              .toList();

          final indexFound = initialValue == null ? 0 : tiersList.indexOf(initialValue!);

          final initialIndex = indexFound >= 0 ? indexFound : 0;

          return ValueScrollPicker(
            looping: false,
            initialItem: initialIndex,
            onSelectedItemChanged: (index) {
              onChanged(tiersList[index]);
            },
            children: possibleTiers,
          );
        },
      ),
    );
  }
}
