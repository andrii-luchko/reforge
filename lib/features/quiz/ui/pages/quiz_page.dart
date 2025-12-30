import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
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
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

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
      body: BlocProvider(
        create: (context) => di.getIt<QuizCubit>(),
        child: DefaultBackground(
          body: const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: QuizForm(),
              ),
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
          loader: Positioned.fill(
            child: BlocSelector<QuizCubit, QuizState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading) {
                return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class QuizForm extends StatefulWidget {
  const QuizForm({super.key});

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    const quizSteps = [
      DateBirthStep(),
      MeasurementSystemStep(),
      MainGoalStep(),
      TrainingLevelStep(),
      WorkoutFrequencyStep(),
      SelectMainFactionStep(),
      SelectSecondFactionStep(),
    ];

    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();

        final isStepValid = cubit.canProceedToNextStep(_currentStepIndex);

        return MultiStepForm(
          steps: quizSteps,
          totalSteps: quizSteps.length,
          backButtonText: t.common.back_button,
          nextButtonText: t.common.next_button,
          finishButtonText: t.common.finish_button,
          isNextButtonEnabled: isStepValid,
          onStepChanged: (newIndex) {
            setState(() {
              _currentStepIndex = newIndex;
            });
          },
          onCompleted: () async {
            await cubit.onSubmit();
          },
        );
      },
    );
  }
}
