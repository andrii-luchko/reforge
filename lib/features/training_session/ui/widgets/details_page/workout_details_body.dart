import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/training_session/controllers/workout_flow/workout_flow_cubit.dart';
import 'package:reforge/features/training_session/ui/widgets/details_page/exercise_section.dart';
import 'package:reforge/features/training_session/ui/widgets/details_page/start_workout_button.dart';
import 'package:reforge/features/training_session/ui/widgets/details_page/workout_details_section.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDetailsBody extends StatelessWidget {
  const WorkoutDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<WorkoutFlowCubit, WorkoutFlowState>(
          builder: (context, state) {
            final isLoading = state.isLoading;

            final programDay = state.programDay;

            if (programDay == null) {
              return const ScreenLoadingIndicator();
            }

            final exercises = programDay.sortedExercises.map((e) => e.exerciseDetails).toList();

            return Skeletonizer(
              enabled: isLoading,
              child: Column(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          WorkoutDetailsSection(
                            title: programDay.name,
                            chips: const [],
                          ),
                          ExerciseSection(
                            exercises: exercises,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: StartWorkoutButton(
                      onPressed: () async {
                        final quizCubit = context.read<WorkoutQuizCubit>();
                        final flowCubit = context.read<WorkoutFlowCubit>();

                        final isTodaySubmitted = await quizCubit.isTodaySubmitted();

                        if (isTodaySubmitted && context.mounted) {
                          await flowCubit.startWorkout();
                          final currentExercise = flowCubit.state.currentExercise;
                          if (currentExercise != null && context.mounted) {
                            unawaited(
                              ActiveWorkoutPageRoute(exerciseId: currentExercise.exerciseDetails.id).push(context),
                            );
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          unawaited(const WorkoutQuizPageRoute().push(context));
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
