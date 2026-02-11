import 'package:flutter/widgets.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/steps.dart';

enum QuizSteps {
  dateBirthStep,
  measurementSystemStep,
  bodyWeightStep,
  mainGoalStep,
  trainingLevelStep,
  workoutFrequencyStep,
  // selectMainFactionStep,
  selectSecondFactionStep,
}

extension QuizStepsX on QuizSteps {
  // ignore: avoid_returning_widgets
  Widget get step {
    return switch (this) {
      QuizSteps.dateBirthStep => const DateBirthStep(),
      QuizSteps.measurementSystemStep => const MeasurementSystemStep(),
      QuizSteps.bodyWeightStep => const BodyWeightStep(),
      QuizSteps.mainGoalStep => const MainGoalStep(),
      QuizSteps.trainingLevelStep => const TrainingLevelStep(),
      QuizSteps.workoutFrequencyStep => const WorkoutFrequencyStep(),
      //QuizSteps.selectMainFactionStep => const SelectMainFactionStep(),
      QuizSteps.selectSecondFactionStep => const SelectSecondFactionStep(),
    };
  }
}
