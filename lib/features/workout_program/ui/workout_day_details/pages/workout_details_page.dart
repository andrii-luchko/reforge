import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/workout_details_body.dart';
import 'package:reforge/features/workout_quiz/ui/widgets/workout_quiz_loader.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutDetailsPage extends StatefulWidget {
  const WorkoutDetailsPage({required this.onStartWorkout, super.key});

  final Future<void> Function() onStartWorkout;

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
    final workoutCubit = context.read<WorkoutProgramCubit>();

    await workoutCubit.init();
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
              userFaction.workoutDetailsTitle(t),
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: DefaultBackground(
        body: WorkoutDetailsBody(onStartWorkout: widget.onStartWorkout),

        loader: const Positioned.fill(child: WorkoutQuizLoader()),
      ),
    );
  }
}
