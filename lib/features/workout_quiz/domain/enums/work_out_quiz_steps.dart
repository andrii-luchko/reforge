import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/enums.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/steps/steps.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_tag.dart';

enum WorkOutQuizSteps {
  sleepQualityStep,
  energizedLevelStep,
  stressLevelStep,
  bodyFellStep,
  hydratedLevelStep,
  hasEatenRecentlyStep,
  isMorningSessionStep,
}

extension WorkOutQuizStepsX on WorkOutQuizSteps {
  Widget get step {
    return switch (this) {
      WorkOutQuizSteps.sleepQualityStep => const SleepQualityStep(),
      WorkOutQuizSteps.energizedLevelStep => const EnergizedLevelStep(),
      WorkOutQuizSteps.stressLevelStep => const StressLevelStep(),
      WorkOutQuizSteps.bodyFellStep => const BodyFeelStep(),
      WorkOutQuizSteps.hydratedLevelStep => const HydratedLevelStep(),
      WorkOutQuizSteps.hasEatenRecentlyStep => const HasEatenStep(),
      WorkOutQuizSteps.isMorningSessionStep => const IsMorningSessionStep(),
    };
  }

  String title(Translations t) {
    return switch (this) {
      WorkOutQuizSteps.sleepQualityStep => t.workout_quiz.step_titles.sleep_quality,
      WorkOutQuizSteps.energizedLevelStep => t.workout_quiz.step_titles.energy_level,
      WorkOutQuizSteps.stressLevelStep => t.workout_quiz.step_titles.stress_level,
      WorkOutQuizSteps.bodyFellStep => t.workout_quiz.step_titles.soreness,
      WorkOutQuizSteps.hydratedLevelStep => t.workout_quiz.step_titles.hydration,
      WorkOutQuizSteps.hasEatenRecentlyStep => t.workout_quiz.step_titles.nutrition,
      WorkOutQuizSteps.isMorningSessionStep => t.workout_quiz.step_titles.fasted_session,
    };
  }

  Widget buildTag(BuildContext context, WorkoutQuizState state) {
    final appTheme = context.appTheme;
    return switch (this) {
      WorkOutQuizSteps.sleepQualityStep => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(SleepQuality.values.length, (index) {
          return Icon(
            Icons.star_rate,
            size: 20,
            color: index < (state.sleepQuality?.score ?? 0) ? appTheme.orange500 : appTheme.beige800,
          );
        }),
      ),
      WorkOutQuizSteps.energizedLevelStep => AppTag(
        text: state.energizedLevel?.title(t) ?? '-',
      ),
      WorkOutQuizSteps.stressLevelStep => AppTag(
        text: state.stressLevel?.title(t) ?? '-',
      ),
      WorkOutQuizSteps.bodyFellStep => AppTag(
        text: state.bodyFeel?.title(t) ?? '-',
      ),
      WorkOutQuizSteps.hydratedLevelStep => AppTag(
        text: state.hydratedLevel?.title(t) ?? '-',
      ),
      WorkOutQuizSteps.hasEatenRecentlyStep => AppTag(
        text: state.hasEatenRecently
            ? t.workout_quiz.steps.has_eaten_recently.eaten
            : t.workout_quiz.steps.has_eaten_recently.fasted,
      ),
      WorkOutQuizSteps.isMorningSessionStep => AppTag(
        text: state.isMorningSession
            ? t.workout_quiz.steps.is_morning_session.yes
            : t.workout_quiz.steps.is_morning_session.no,
      ),
    };
  }
}
