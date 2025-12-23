import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/ui/widgets/date_piker.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class DateBirthStep extends StatelessWidget {
  const DateBirthStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.date_of_birth.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        LabeledAppTextField(
          label: t.quiz.steps.date_of_birth.select_date_label,
          field: FieldDatePicker(
            onDateSelected: (value) {},
          ),
        ),
      ],
    );
  }
}
