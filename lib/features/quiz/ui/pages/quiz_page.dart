import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/quiz_steps.dart';
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
      extendBodyBehindAppBar: true,
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
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: QuizForm(),
              ),
            ),
          ),
          additionalAnimationsOnTop: [
            Positioned.fill(
              child: SunRaysShaderWidget.fromTop(color: appTheme.orange500),
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

class QuizForm extends StatelessWidget {
  const QuizForm({super.key});

  @override
  Widget build(BuildContext context) {
    final quizSteps = QuizSteps.values
        .map(
          (s) => SingleChildScrollView(
            child: s.step,
          ),
        )
        .toList();

    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state.isSubmitted) const HomePageRoute().go(context);
      },
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();

        return MultiStepForm(
          steps: quizSteps,
          totalSteps: quizSteps.length,
          backButtonText: t.common.back_button,
          nextButtonText: t.common.next_button,
          finishButtonText: t.common.finish_button,
          isNextButtonEnabled: cubit.isStepValid,
          onStepChanged: cubit.onStepChanged,
          onCompleted: () async {
            await cubit.onSubmit();
          },
        );
      },
    );
  }
}
