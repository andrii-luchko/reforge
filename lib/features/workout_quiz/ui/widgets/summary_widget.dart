import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class SummaryQuizWidget extends StatelessWidget {
  const SummaryQuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return BlocBuilder<WorkoutQuizCubit, WorkoutQuizState>(
      builder: (context, state) {
        final summaryItems = WorkOutQuizSteps.values.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return SummaryRowWidget(
            number: index + 1,
            title: step.title(t),
            tag: step.buildTag(context, state),
          );
        }).toList();

        return BlurContainer(
          sigmaX: 20,
          sigmaY: 20,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _addDividers(summaryItems, appTheme),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _addDividers(List<Widget> items, AppTheme appTheme) {
    if (items.isEmpty) return [];

    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          Divider(
            height: 24,
            color: appTheme.beige700,
          ),
        );
      }
    }
    return result;
  }
}

class SummaryRowWidget extends StatelessWidget {
  const SummaryRowWidget({required this.number, required this.title, required this.tag, super.key});

  final int number;
  final String title;
  final Widget tag;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Text('0$number/', style: subheadH3Medium.copyWith(color: appTheme.orange500)),
        const SizedBox(width: 7),
        Text(title, style: subheadH3Medium.copyWith(color: appTheme.beige100)),
        const Spacer(),
        tag,
      ],
    );
  }
}
