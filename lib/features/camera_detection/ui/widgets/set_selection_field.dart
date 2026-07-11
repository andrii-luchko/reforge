import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class SetSelectionField extends StatelessWidget {
  const SetSelectionField({
    required this.controller,
    required this.setList,
    required this.onChanged,
    this.initialValue,
    super.key,
  });

  final TextEditingController controller;
  final WorkoutSet? initialValue;
  final List<WorkoutSet> setList;
  final ValueChanged<WorkoutSet> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = subheadH3Medium.copyWith(color: context.appTheme.beige100);

    return LabeledAppTextField(
      label: 'Select set',
      field: PortalSelectField(
        controller: controller,
        hintText: 'Select set',
        heightFactor: setList.length > 3 ? 3 : 2,
        contentBuilder: (context, close) {
          if (setList.isEmpty) {
            return Center(
              child: Text(
                'No options to select',
                style: style,
              ),
            );
          }

          final possibleSets = setList
              .mapIndexed(
                (index, set) => Center(
                  child: Text('Set ${set.setNumber}', style: style),
                ),
              )
              .toList();

          final indexFound = initialValue == null ? 0 : setList.indexOf(initialValue!);
          final initialIndex = indexFound >= 0 ? indexFound : 0;

          return ValueScrollPicker(
            looping: false,
            initialItem: initialIndex,
            onSelectedItemChanged: (index) {
              onChanged(setList[index]);
            },
            children: possibleSets,
          );
        },
      ),
    );
  }
}
