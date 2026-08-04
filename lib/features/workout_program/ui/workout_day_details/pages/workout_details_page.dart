import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/workout_program/controllers/free_run_details_cubit.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/workout_details_body.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
import 'package:reforge/features/workout_session/ui/widgets/workout_flow_loader.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutDetailsPage extends StatefulWidget {
  const WorkoutDetailsPage({
    required this.intent,
    required this.onStartWorkout,
    super.key,
  });

  final WorkoutStartIntent intent;
  final Future<void> Function(WorkoutExecutionPlan? plan) onStartWorkout;

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
    switch (widget.intent) {
      case WorkoutStartIntent.program:
        await context.read<WorkoutProgramCubit>().init();
        return;
      case WorkoutStartIntent.freeRun:
        await context.read<FreeRunDetailsCubit>().load();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final userFaction =
        context.read<UserCubit>().state.maybeMap(
          orElse: () => Faction.gakki,
          loaded: (state) => state.user.maybeMap(
            orElse: () => Faction.gakki,
            onboarded: (u) => Faction.fromId(u.factionId),
          ),
        ) ??
        Faction.gakki;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,

      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              widget.intent == WorkoutStartIntent.freeRun
                  ? context.t.workout_details.freeRunTitle
                  : userFaction.workoutDetailsTitle(t),
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: DefaultBackground(
        body: switch (widget.intent) {
          WorkoutStartIntent.program => WorkoutDetailsBody(
            onStartWorkout: () => widget.onStartWorkout(null),
          ),
          WorkoutStartIntent.freeRun => BlocSelector<FreeRunDetailsCubit, FreeRunDetailsState, WorkoutExecutionPlan?>(
            selector: (state) => state.executionPlan,
            builder: (context, plan) => FreeRunDetailsBody(
              onStartWorkout: () async {
                if (plan != null) await widget.onStartWorkout(plan);
              },
            ),
          ),
        },

        loader: const Positioned.fill(child: WorkoutFlowLoader()),
      ),
    );
  }
}
