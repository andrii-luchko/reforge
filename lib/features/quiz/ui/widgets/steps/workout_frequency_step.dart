import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';

class WorkoutFrequencyStep extends StatelessWidget {
  const WorkoutFrequencyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.workout_frequency.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_days_label,
          field: PortalSelectField(
            hintText: t.quiz.steps.workout_frequency.select_days_hint,
            contentBuilder: (_, _) {
              return Container(
                height: 200,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_specific_days_label,
          field: PortalSelectField(
            hintText: t.quiz.steps.workout_frequency.select_specific_days_hint,
            contentBuilder: (_, _) {
              return Container(
                height: 200,
              );
            },
          ),
        ),
      ],
    );
  }
}
