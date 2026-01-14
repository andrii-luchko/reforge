import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/body_feel.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/quiz_title_section.dart';

class BodyFeelStep extends StatelessWidget {
  const BodyFeelStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizTitleSection(
          title: t.workout_quiz.steps.body_feel.title,
          subtitle: t.workout_quiz.steps.body_feel.subtitle,
        ),
        const SizedBox(height: 32),
        BlocSelector<WorkoutQuizCubit, WorkoutQuizState, BodyFeel?>(
          selector: (state) => state.bodyFeel,
          builder: (context, value) {
            final cubit = context.read<WorkoutQuizCubit>();
            return Column(
              children: BodyFeel.values.map((feel) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RadioButtonOption(
                    title: feel.title(t),
                    isSelected: value == feel,
                    onTap: () => cubit.setBodyFeel(feel),
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
