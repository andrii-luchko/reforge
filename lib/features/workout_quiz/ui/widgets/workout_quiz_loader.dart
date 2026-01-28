import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class WorkoutQuizLoader extends StatelessWidget {
  const WorkoutQuizLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkoutQuizCubit, WorkoutQuizState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
