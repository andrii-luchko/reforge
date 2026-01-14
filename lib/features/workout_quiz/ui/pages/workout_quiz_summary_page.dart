import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutQuizSummaryPage extends StatelessWidget {
  const WorkoutQuizSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      body: const DefaultBackground(
        body: SafeArea(child: Column()),
      ),
    );
  }
}
