import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/features/training_session/ui/controllers/workout_quiz/workout_quiz_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
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
      extendBody: true,

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
      body: BlocProvider(
        create: (context) => di.getIt<WorkoutQuizCubit>(),
        child: const DefaultBackground(body: WorkoutQuizBody()),
      ),
    );
  }
}

class WorkoutQuizBody extends StatelessWidget {
  const WorkoutQuizBody({super.key});

  @override
  Widget build(BuildContext context) {
    final quizSteps = WorkOutQuizSteps.values.map((s) => s.step).toList();

    return BlocConsumer<WorkoutQuizCubit, WorkoutQuizState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<WorkoutQuizCubit>();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
