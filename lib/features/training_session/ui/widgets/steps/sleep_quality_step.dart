import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/training_session/domain/enums/sleep_quality.dart';
import 'package:reforge/features/training_session/ui/controllers/workout_quiz/workout_quiz_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/quiz_title_section.dart';

class SleepQualityStep extends StatelessWidget {
  const SleepQualityStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizTitleSection(
          title: t.workout_quiz.steps.sleep_quality.title,
          subtitle: t.workout_quiz.steps.sleep_quality.subtitle,
        ),
        const SizedBox(height: 32),
        BlocSelector<WorkoutQuizCubit, WorkoutQuizState, SleepQuality?>(
          selector: (state) => state.sleepQuality,
          builder: (context, value) {
            final cubit = context.read<WorkoutQuizCubit>();
            return Column(
              children: SleepQuality.values.map((quality) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RadioButtonOption(
                    title: quality.title(t),
                    isSelected: value == quality,
                    onTap: () => cubit.setSleepQuality(quality),
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
