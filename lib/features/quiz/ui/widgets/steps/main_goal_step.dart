import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/ui/widgets/fitness_goal_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class MainGoalStep extends StatelessWidget {
  const MainGoalStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.main_goal.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        BlocSelector<QuizCubit, QuizState, MainGoal?>(
          selector: (state) => state.mainGoal,
          builder: (context, selectedGoal) {
            final cubit = context.read<QuizCubit>();
            return FitnessGoalSelector(
              selectedGoal: selectedGoal,
              onGoalChanged: cubit.setMainGoal,
            );
          },
        ),
      ],
    );
  }
}
