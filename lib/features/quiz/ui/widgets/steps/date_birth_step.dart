import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';

import 'package:reforge/features/quiz/ui/widgets/date_text_field.dart';
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
        BlocSelector<QuizCubit, QuizState, (DateTime?, String?)>(
          selector: (state) => (state.dateOfBirth, state.dateOfBirthError),
          builder: (context, dateData) {
            final cubit = context.read<QuizCubit>();

            return LabeledAppTextField(
              label: t.quiz.steps.date_of_birth.select_date_label,
              field: DateInputField(
                initialDate: dateData.$1,
                errorText: dateData.$2,
                onDateSelected: cubit.setDateOfBirth,
              ),
            );
            // return LabeledAppTextField(
            //   label: t.quiz.steps.date_of_birth.select_date_label,
            //   field: FieldDatePicker(
            //     hintText: t.quiz.steps.date_of_birth.select_date_label,
            //     initialDate: dateData.$1,
            //     errorText: dateData.$2,
            //     onDateSelected: cubit.setDateOfBirth,
            //   ),
            // );
          },
        ),
      ],
    );
  }
}
