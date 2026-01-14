import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

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
              'Pre-Workout Check-In',
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: WorkoutQuizBody()),
    );
  }
}

class WorkoutQuizBody extends StatelessWidget {
  const WorkoutQuizBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: .spaceBetween, children: []),
      ),
    );
  }
}
