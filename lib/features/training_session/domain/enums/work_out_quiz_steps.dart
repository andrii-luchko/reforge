import 'package:flutter/widgets.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/body_feel_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/energized_level_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/has_eaten_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/hydrated_level_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/is_morning_session_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/sleep_quality_step.dart';
import 'package:reforge/features/training_session/ui/widgets/steps/stress_level_step.dart';

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
