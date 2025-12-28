import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/date_birth_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/main_goal_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/measurement_system_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/select_main_faction_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/select_second_faction_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/training_level_step.dart';
import 'package:reforge/features/quiz/ui/widgets/steps/workout_frequency_step.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/multi_step_form.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              t.quiz.header,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: DefaultBackground(
        body: const Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(child: QuizForm()),
          ),
        ),

        additionalAnimations: [
          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              alignment: .topCenter,
              rayLength: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizForm extends StatelessWidget {
  const QuizForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiStepForm(
      steps: const [
        DateBirthStep(),
        MeasurementSystemStep(),
        MainGoalStep(),
        TrainingLevelStep(),
        WorkoutFrequencyStep(),
        SelectMainFactionStep(),
        SelectSecondFactionStep(),
      ],
      totalSteps: 7,
      backButtonText: t.common.back_button,
      nextButtonText: t.common.next_button,
      finishButtonText: t.common.finish_button,
      onCompleted: () {
        // Handle quiz completion
        // TODO: Navigate to next screen or submit quiz data
      },
    );
  }
}
