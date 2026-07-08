import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/features/workout_details/ui/widgets/details_page/workout_details_body.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/workout_quiz_loader.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class ScheduledWorkoutDetailsPage extends StatefulWidget {
  const ScheduledWorkoutDetailsPage({
    required this.scheduledWorkoutDayId,
    required this.date,
    super.key,
  });

  final int scheduledWorkoutDayId;
  final DateTime date;

  @override
  State<ScheduledWorkoutDetailsPage> createState() => _ScheduledWorkoutDetailsPageState();
}

class _ScheduledWorkoutDetailsPageState extends State<ScheduledWorkoutDetailsPage> {
  @override
  void initState() {
    super.initState();

    unawaited(context.read<WorkoutFlowCubit>().initWorkoutFromCalendar(widget.scheduledWorkoutDayId));
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
              t.training_details.trainingDateTitle(date: widget.date.toDotString()),
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
