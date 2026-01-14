import 'package:flutter/widgets.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/steps/steps.dart';

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
}
