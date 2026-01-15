import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/hydrated_level.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/quiz_title_section.dart';

class HydratedLevelStep extends StatelessWidget {
  const HydratedLevelStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizTitleSection(
          title: t.workout_quiz.steps.hydrated_level.title,
          subtitle: t.workout_quiz.steps.hydrated_level.subtitle,
        ),
        const SizedBox(height: 32),
        BlocSelector<WorkoutQuizCubit, WorkoutQuizState, HydratedLevel?>(
          selector: (state) => state.hydratedLevel,
          builder: (context, value) {
            final cubit = context.read<WorkoutQuizCubit>();
            return Column(
              children: HydratedLevel.values.map((level) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RadioButtonOption(
                    title: level.title(t),
                    isSelected: value == level,
                    onTap: () => cubit.setHydratedLevel(level),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
