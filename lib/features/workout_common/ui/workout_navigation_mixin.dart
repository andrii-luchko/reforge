import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';

/// Provides [handleStartWorkout] — the single entry point for starting a fresh workout session from any screen.
///
/// Restore flow (interrupted session detection + resume) is handled separately by WorkoutRestoreCubit and its UI listener in HomeBody.
mixin WorkoutNavigationMixin {
  Future<void> handleStartWorkout(BuildContext context) async {
    final quizCubit = context.read<WorkoutQuizCubit>();
    final flowCubit = context.read<WorkoutFlowCubit>();

    final isTodaySubmitted = await quizCubit.isTodaySubmitted();

    if (!context.mounted) return;

    if (isTodaySubmitted) {
      await flowCubit.startWorkout();

      if (!context.mounted) return;

      final exercise = flowCubit.state.currentExercise;
      if (exercise != null) {
        ActiveWorkoutPageRoute(programExerciseId: exercise.id).go(context);
      }
    } else {
      unawaited(const WorkoutQuizPageRoute().push(context));
    }
  }
}
