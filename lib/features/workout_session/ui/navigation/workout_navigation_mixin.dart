import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_source.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
import 'package:toastification/toastification.dart';

/// Provides [handleStartWorkout] — the single entry point for starting a fresh workout session from any screen.
///
/// Restore flow (interrupted session detection + resume) is handled separately by WorkoutRestoreCubit and its UI listener in HomeBody.
mixin WorkoutNavigationMixin {
  Future<void> handleStartWorkout(
    BuildContext context, {
    WorkoutExecutionPlan? plan,
  }) async {
    final quizCubit = context.read<WorkoutQuizCubit>();
    final flowCubit = context.read<WorkoutSessionFlowCubit>();
    final programDay = plan == null ? context.read<WorkoutProgramCubit>().state.programDay : null;
    final preparedPlan = plan ?? (programDay == null ? null : WorkoutExecutionPlan.fromProgramDay(programDay));
    if (preparedPlan == null) return;

    flowCubit.prepareWorkout(
      preparedPlan,
      intent: preparedPlan.source is ProgramWorkoutSource ? WorkoutStartIntent.program : WorkoutStartIntent.freeRun,
      programDay: programDay,
    );

    final isTodaySubmitted = await quizCubit.isTodaySubmitted();

    if (!context.mounted) return;

    if (isTodaySubmitted) {
      await handleStartPreparedWorkout(context);
    } else {
      unawaited(const WorkoutQuizPageRoute().push(context));
    }
  }

  Future<void> handleStartPreparedWorkout(BuildContext context) async {
    final result = await context.read<WorkoutSessionFlowCubit>().startPreparedWorkout();
    if (!context.mounted) return;

    switch (result) {
      case Success(value: final execution):
        ActiveExercisePageRoute(executionKey: execution.spec.executionKey).go(context);
      case Failure(:final error):
        toastification.showErrorToast(error.toString(), context);
    }
  }
}
