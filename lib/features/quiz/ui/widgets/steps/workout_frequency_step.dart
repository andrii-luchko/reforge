import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/settings/ui/page/settings_content/workout_days_content.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutFrequencyStep extends StatelessWidget {
  const WorkoutFrequencyStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.workout_frequency.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        BlocBuilder<QuizCubit, QuizState>(
          buildWhen: (p, c) =>
              p.workoutDaysPerWeek != c.workoutDaysPerWeek || p.specificWorkoutDays != c.specificWorkoutDays,
          builder: (context, state) {
            return WorkoutFrequencyPicker(
              daysPerWeek: state.workoutDaysPerWeek,
              specificDays: state.specificWorkoutDays,
              onDaysPerWeekChanged: cubit.setWorkoutDays,
              onSpecificDaysChanged: cubit.setSpecificDays,
            );
          },
        ),
      ],
    );
  }
}
