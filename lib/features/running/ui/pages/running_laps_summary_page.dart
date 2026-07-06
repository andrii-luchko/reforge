// ignore_for_file: comment_references

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/workout_section.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/ui/widgets/running_laps_list.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:toastification/toastification.dart';

class RunningLapsSummaryPage extends StatelessWidget {
  const RunningLapsSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final measureSystem = context.read<ActiveExerciseCubit>().state.measureSystem;

    return BlocListener<RunningTrackerCubit, RunningTrackerState>(
      listenWhen: (prev, curr) => prev.error != curr.error,
      listener: (context, state) {
        if (state.error case final err?) {
          toastification.showErrorToast(err, context);
        }
      },
      child: BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
        builder: (context, state) {
          final cubit = context.read<RunningTrackerCubit>();
          final activeExerciseCubit = context.watch<ActiveExerciseCubit>();
          final programExercise = cubit.programExercise;
          final exerciseDetails = programExercise.exerciseDetails;

          final completedLaps = activeExerciseCubit.state.sets.where((set) => set.isDone).map((set) {
            final segment = set.programSegmentId == null
                ? null
                : programExercise.segments.firstWhereOrNull((segment) => segment.id == set.programSegmentId);
            return ExerciseLap(
              lapNumber: set.setNumber ?? 0,
              distanceMeters: (set.distance ?? 0) * 1000,
              durationSeconds: set.time?.inSeconds ?? 0,
              avgSpeedKmH: set.pace ?? 0, // Fallback to pace as speed for old records
              currentSpeedKmH: 0,
              avgPaceMinKm: (set.pace ?? 0) > 0 ? 60.0 / set.pace! : 0,
              currentPaceMinKm: 0,
              activity: segment?.activity ?? SegmentActivity.run,
            );
          }).toList();

          return DefaultBackground(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: AppTextField(
                                hintText: t.workout.addNotesHint,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: context.read<ActiveExerciseCubit>().setNote,
                              ),
                            ),

                            WorkoutSection(exercise: exerciseDetails),
                            const SizedBox(height: 16),

                            RunningLapsList(
                              laps: completedLaps,
                              metrics: exerciseDetails.metrics,
                              system: measureSystem,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    SecondaryButton(
                      text: 'Back to Running',
                      onPressed: cubit.goToActive,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Finish Exercise',
                      onPressed: state.isSubmitting ? null : () => unawaited(_onFinishExercise(context, cubit)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onFinishExercise(BuildContext context, RunningTrackerCubit cubit) async {
    final success = await cubit.finishExercise();
    if (!success || !context.mounted) return;

    final timerDuration = context.read<TimerCubit>().state.duration;
    await context.read<WorkoutFlowCubit>().nextExercise(timerDuration);
  }
}
