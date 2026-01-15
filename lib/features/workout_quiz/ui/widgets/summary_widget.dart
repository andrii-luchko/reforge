import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/staggered_summary_card.dart';

class SummaryQuizWidget extends StatelessWidget {
  const SummaryQuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutQuizCubit, WorkoutQuizState>(
      builder: (context, state) {
        final rows = WorkOutQuizSteps.values.asMap().entries.map((entry) {
          return SummaryRowWidget(
            number: entry.key + 1,
            title: entry.value.title(t),
            tag: entry.value.buildTag(context, state),
          );
        }).toList();

        return StaggeredSummaryCard(items: rows);
      },
    );
  }
}
