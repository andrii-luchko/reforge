import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_details/ui/widgets/details_page/workout_details_body.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/workout_quiz_loader.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutDetailsPage extends StatefulWidget {
  const WorkoutDetailsPage({super.key});

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  @override
  void initState() {
    super.initState();

    unawaited(_init());
  }

  Future<void> _init() async {
    final workoutCubit = context.read<WorkoutFlowCubit>();

    await workoutCubit.init();
  }

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
              t.workout_details.title,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(
        body: WorkoutDetailsBody(),

        loader: Positioned.fill(child: WorkoutQuizLoader()),
      ),
    );
  }
}
