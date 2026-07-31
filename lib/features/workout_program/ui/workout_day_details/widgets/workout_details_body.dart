import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_program/data/mock/mocked_day.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/exercise_section.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/start_workout_button.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/widgets/workout_details_section.dart';
import 'package:reforge/shared/uikit/states/no_workout_error_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDetailsBody extends StatelessWidget {
  const WorkoutDetailsBody({required this.onStartWorkout, super.key});

  final Future<void> Function() onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
          builder: (context, state) {
            final isLoading = state.isLoading;

            final programDay = isLoading ? mockProgramDay : state.programDay;

            if (programDay == null) {
              return const Center(child: NoWorkoutErrorWidget());
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
                        unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.workoutDetailsStartClick));
                        await onStartWorkout();
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
