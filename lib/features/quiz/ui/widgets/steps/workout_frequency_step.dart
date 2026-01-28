import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/ui/widgets/horizontal_day_piker.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class WorkoutFrequencyStep extends StatefulWidget {
  const WorkoutFrequencyStep({super.key});

  @override
  State<WorkoutFrequencyStep> createState() => _WorkoutFrequencyStepState();
}

class _WorkoutFrequencyStepState extends State<WorkoutFrequencyStep> {
  late final QuizCubit cubit = context.read<QuizCubit>();
  late final List<Text> _numberDaysList;

  final _numberCountController = TextEditingController();
  final _numberCountPortalController = PortalSelectController();
  final _specificDaysController = TextEditingController();

  final _specificDaysPortalController = PortalSelectController();

  @override
  void initState() {
    super.initState();
    final selectedDaysNumber = cubit.state.workoutDaysPerWeek;
    if (selectedDaysNumber != null) {
      _numberCountController.text = selectedDaysNumber.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _numberDaysList = List.generate(3, (i) {
      final dayValue = i + 3;

      return Text(
        '$dayValue',
        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
      );
    });

    final specificDays = cubit.state.specificWorkoutDays;
    if (specificDays.isNotEmpty) {
      _updateSpecificDaysText(specificDays);
    }
  }

  void _updateSpecificDaysText(List<WeekDay> value) {
    final copy = List<WeekDay>.from(value)..sort((a, b) => a.value.compareTo(b.value));

    final text = copy.map<String>((day) => day.label(context)).join(', ');

    if (_specificDaysController.text != text) {
      _specificDaysController.text = text;
    }
  }

  @override
  void dispose() {
    _numberCountController.dispose();
    _specificDaysController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.workout_frequency.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        BlocSelector<QuizCubit, QuizState, int?>(
          selector: (state) => state.workoutDaysPerWeek,

          builder: (context, days) {
            return LabeledAppTextField(
              label: t.quiz.steps.workout_frequency.select_days_label,
              field: PortalSelectField(
                key: const ValueKey('numbers'),
                controller: _numberCountController,
                hintText: t.quiz.steps.workout_frequency.select_days_hint,
                onTap: _specificDaysPortalController.close,
                contentBuilder: (_, _) {
                  final selectedDaysNumber = cubit.state.workoutDaysPerWeek;
                  final initialItem = (selectedDaysNumber != null && selectedDaysNumber >= 3)
                      ? (selectedDaysNumber - 3)
                      : 0;

                  return ValueScrollPicker(
                    initialItem: initialItem,

                    onSelectedItemChanged: (index) {
                      final daysCount = index + 3;
                      _numberCountController.text = daysCount.toString();
                      cubit.setWorkoutDays(daysCount);
                    },
                    children: _numberDaysList,
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        BlocSelector<QuizCubit, QuizState, (int?, List<WeekDay>)>(
          selector: (state) => (state.workoutDaysPerWeek, state.specificWorkoutDays),

          builder: (context, frequency) {
            return LabeledAppTextField(
              key: const ValueKey('specific'),
              label: t.quiz.steps.workout_frequency.select_specific_days_label,
              field: PortalSelectField(
                portalController: _specificDaysPortalController,
                controller: _specificDaysController,
                hintText: t.quiz.steps.workout_frequency.select_specific_days_hint,
                onTap: _numberCountPortalController.close,
                contentBuilder: (context, _) {
                  return HorizontalWeekDaysPicker(
                    maxSelections: frequency.$1 ?? 0,
                    initialValue: frequency.$2,
                    onChanged: (list) {
                      _updateSpecificDaysText(list);
                      cubit.setSpecificDays(list);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
