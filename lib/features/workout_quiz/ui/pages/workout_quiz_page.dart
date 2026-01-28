import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/workout_quiz_loader.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/multi_step_form.dart';

class WorkoutQuizPage extends StatelessWidget {
  const WorkoutQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,

      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              t.workout_quiz.header,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: DefaultBackground(
        body: const WorkoutQuizBody(),
        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.fromTop(color: appTheme.orange500),
          ),
        ],
        loader: const Positioned.fill(child: WorkoutQuizLoader()),
      ),
    );
  }
}

class WorkoutQuizBody extends StatelessWidget {
  const WorkoutQuizBody({super.key});

  @override
  Widget build(BuildContext context) {
    final quizSteps = WorkOutQuizSteps.values
        .map(
          (s) => SingleChildScrollView(
            child: s.step,
          ),
        )
        .toList();

    return BlocConsumer<WorkoutQuizCubit, WorkoutQuizState>(
      listener: (context, state) {
        if (state.isSubmitted) const WorkoutQuizSummaryPageRoute().go(context);
      },
      builder: (context, state) {
        final cubit = context.read<WorkoutQuizCubit>();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MultiStepForm(
              steps: quizSteps,
              totalSteps: quizSteps.length,
              backButtonText: t.common.back_button,
              nextButtonText: t.common.next_button,
              finishButtonText: t.common.finish_button,
              isNextButtonEnabled: cubit.isStepValid,
              onStepChanged: cubit.onStepChanged,
              onCompleted: cubit.onSubmit,
            ),
          ),
        );
      },
    );
  }
}
