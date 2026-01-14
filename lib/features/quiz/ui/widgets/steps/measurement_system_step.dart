import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/ui/widgets/measure_switcher.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class MeasurementSystemStep extends StatelessWidget {
  const MeasurementSystemStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.measurement_system.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),

        BlocSelector<QuizCubit, QuizState, MeasurementSystem>(
          selector: (state) => state.measurementSystem,
          builder: (context, system) {
            final cubit = context.read<QuizCubit>();
            return MeasureSwitcher(
              selectedMeasure: system,
              onSelected: cubit.setMeasurementSystem,
            );
          },
        ),
      ],
    );
  }
}
