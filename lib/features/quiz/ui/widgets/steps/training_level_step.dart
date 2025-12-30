import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';

import 'package:reforge/features/quiz/domain/enums/training_level.dart';
import 'package:reforge/features/quiz/ui/widgets/training_level_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class TrainingLevelStep extends StatelessWidget {
  const TrainingLevelStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.training_level.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),

        BlocSelector<QuizCubit, QuizState, TrainingLevel?>(
          selector: (state) => state.trainingLevel,
          builder: (context, level) {
            final cubit = context.read<QuizCubit>();
            return TrainingLevelSelector(
              selectedLevel: level,
              onLevelChanged: cubit.setTrainingLevel,
            );
          },
        ),
      ],
    );
  }
}
