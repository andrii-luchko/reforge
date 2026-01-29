import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/training_session/ui/mixins/workout_navigation_mixin.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/summary_widget.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/workout_quiz_loader.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutQuizSummaryPage extends StatelessWidget {
  const WorkoutQuizSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,

      body: DefaultBackground(
        body: const WorkoutQuizSummaryBody(),
        additionalAnimationsOnTop: [
          Positioned.fill(child: SunRaysShaderWidget.fromTop(color: appTheme.orange500)),
          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              alignment: const Alignment(0, 0.05),
              rayLength: 0.03,
              density: 1,
            ),
          ),
        ],
        loader: const Positioned.fill(child: WorkoutQuizLoader()),
      ),
    );
  }
}

class WorkoutQuizSummaryBody extends StatelessWidget with WorkoutNavigationMixin {
  const WorkoutQuizSummaryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Spacer(),
            CenteredTitleSection(
              title: t.workout_quiz.quiz_summary.title,
              subtitle: t.workout_quiz.quiz_summary.subtitle,
            ),
            const SizedBox(height: 32),
            const SummaryQuizWidget(),
            const Spacer(),
            PrimaryButton(
              text: t.workout_quiz.quiz_summary.button_label,
              onPressed: () async => handleStartWorkout(context),
            ),
          ],
        ),
      ),
    );
  }
}
