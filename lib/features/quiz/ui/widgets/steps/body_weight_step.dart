import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/settings/ui/page/settings_content/height_and_weight_content.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class BodyWeightStep extends StatelessWidget {
  const BodyWeightStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.body_weight.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        BlocSelector<QuizCubit, QuizState, int?>(
          selector: (state) => state.bodyWeight,
          builder: (context, bodyWeight) {
            final cubit = context.read<QuizCubit>();
            return WeightSelectField(
              label: t.quiz.steps.body_weight.select_body_weight_label,
              hintText: t.quiz.steps.body_weight.select_body_weight_label,

              value: bodyWeight?.toDouble(),
              measurementSystem: cubit.state.measurementSystem,
              onChanged: (value) => cubit.setBodyWeight(value.toInt()),
            );
          },
        ),
      ],
    );
  }
}
