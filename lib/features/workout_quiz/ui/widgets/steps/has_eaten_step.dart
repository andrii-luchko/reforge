import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/quiz_title_section.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';

class HasEatenStep extends StatelessWidget {
  const HasEatenStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizTitleSection(
          title: t.workout_quiz.steps.has_eaten_recently.title,
          subtitle: t.workout_quiz.steps.has_eaten_recently.subtitle,
        ),
        const SizedBox(height: 32),
        BlocSelector<WorkoutQuizCubit, WorkoutQuizState, bool>(
          selector: (state) => state.hasEatenRecently,
          builder: (context, value) {
            final cubit = context.read<WorkoutQuizCubit>();
            return MultiOptionSwitcher<bool>(
              selectedValue: value,
              values: const [true, false],
              labelBuilder: (value) =>
                  value ? t.workout_quiz.steps.has_eaten_recently.yes : t.workout_quiz.steps.has_eaten_recently.no,
              onSelected: cubit.setHasEatenRecently,
            );
          },
        ),
      ],
    );
  }
}
