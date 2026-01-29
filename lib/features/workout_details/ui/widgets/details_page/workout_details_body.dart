import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_common/ui/workout_navigation_mixin.dart';
import 'package:reforge/features/workout_details/ui/widgets/details_page/exercise_section.dart';
import 'package:reforge/features/workout_details/ui/widgets/details_page/start_workout_button.dart';
import 'package:reforge/features/workout_details/ui/widgets/details_page/workout_details_section.dart';

import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDetailsBody extends StatelessWidget with WorkoutNavigationMixin {
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
                    child: StartWorkoutButton(onPressed: () async => handleStartWorkout(context)),
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
