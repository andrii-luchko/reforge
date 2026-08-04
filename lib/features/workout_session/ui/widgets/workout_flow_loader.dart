import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class WorkoutFlowLoader extends StatelessWidget {
  const WorkoutFlowLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final quizLoading = context.select<WorkoutQuizCubit, bool>((cubit) => cubit.state.isLoading);
    final workoutStarting = context.select<WorkoutSessionFlowCubit, bool>(
      (cubit) => cubit.state.isStartingWorkout,
    );
    return quizLoading || workoutStarting ? const ScreenLoadingIndicator() : const SizedBox.shrink();
  }
}
