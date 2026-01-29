import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';

mixin WorkoutNavigationMixin {
  Future<void> handleStartWorkout(BuildContext context) async {
    final quizCubit = context.read<WorkoutQuizCubit>();
    final flowCubit = context.read<WorkoutFlowCubit>();

    final isTodaySubmitted = await quizCubit.isTodaySubmitted();

    if (!context.mounted) return;

    if (isTodaySubmitted) {
      await flowCubit.startWorkout();

      if (!context.mounted) return;

      final currentExercise = flowCubit.state.currentExercise;
      if (currentExercise != null) {
        unawaited(
          ActiveWorkoutPageRoute(
            exerciseId: currentExercise.exerciseDetails.id,
          ).push(context),
        );
      }
    } else {
      unawaited(const WorkoutQuizPageRoute().push(context));
    }
  }
}
