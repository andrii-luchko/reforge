import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/training_session/ui/controllers/workout_quiz/workout_quiz_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/quiz_title_section.dart';
import 'package:reforge/shared/uikit/binary_option_switcher.dart';

class IsMorningSessionStep extends StatelessWidget {
  const IsMorningSessionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizTitleSection(
          title: t.workout_quiz.steps.is_morning_session.title,
          subtitle: t.workout_quiz.steps.is_morning_session.subtitle,
        ),
        const SizedBox(height: 32),
        BlocSelector<WorkoutQuizCubit, WorkoutQuizState, bool>(
          selector: (state) => state.isMorningSession,
          builder: (context, value) {
            final cubit = context.read<WorkoutQuizCubit>();
            return BinaryOptionSwitcher<bool>(
              selectedValue: value,
              firstValue: true,
              secondValue: false,
              labelBuilder: (value) => value ? t.workout_quiz.steps.is_morning_session.yes : t.workout_quiz.steps.is_morning_session.no,
              onSelected: cubit.setIsMorningSession,
            );
          },
        ),
      ],
    );
  }
}
