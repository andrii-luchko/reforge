import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/workout_section.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/ui/widgets/running_map_view.dart';
import 'package:reforge/features/running/ui/widgets/running_metrics_panel.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:toastification/toastification.dart';

class RunningActivePage extends StatelessWidget {
  const RunningActivePage({super.key});

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
          final programExercise = cubit.programExercise;
          final exerciseDetails = programExercise.exerciseDetails;
          final lap = state.currentLap;

          return DefaultBackground(
            body: SafeArea(
              child: Column(
                children: [
                  switch (state.mode) {
                    .gps => Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),

                            child: lap != null
                                ? RunningMetricsPanel.fromExerciseLap(
                                    lap,
                                    measureSystem,
                                    isLive: !state.isPaused,
                                  )
                                : RunningMetricsPanel(
                                    distanceMeters: 0,
                                    durationSeconds: 0,
                                    paceKmH: 0,

                                    system: measureSystem,
                                  ),
                          ),

                          Expanded(
                            child: Stack(
                              children: [
                                RunningMapView(routeMap: state.routeMap),
                                //TODO: Lately show pause tag based on cubit value acros two modes
                                const Positioned(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  child: AppTag(
                                    text: 'Paused',
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    .pedometer => Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AppTextField(
                                hintText: t.workout.addNotesHint,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: context.read<ActiveExerciseCubit>().setNote,
                              ),
                            ),

                            WorkoutSection(exercise: exerciseDetails),
                            const SizedBox(height: 32),

                            if (lap != null)
                              RunningMetricsPanel.fromExerciseLap(
                                lap,
                                measureSystem,
                                isLive: !state.isPaused,
                              )
                            else
                              RunningMetricsPanel(
                                distanceMeters: 0,
                                durationSeconds: 0,
                                paceKmH: 0,

                                system: measureSystem,
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    _ => Container(),
                  },
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ActionButtons(state: state, cubit: cubit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.state, required this.cubit});

  final RunningTrackerState state;
  final RunningTrackerCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (state.isPaused) {
      // Paused state: Resume + Finish
      return Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Finish',
              onPressed: () async {
                await cubit.endWorkout();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: 'Resume',
              onPressed: cubit.resumeLap,
            ),
          ),
        ],
      );
    }

    // Active state: Pause + Next Lap
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Next Lap',
            onPressed: state.isSubmitting ? null : () async => cubit.forceNextLap(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            text: 'Pause',
            onPressed: cubit.pauseLap,
          ),
        ),
      ],
    );
  }
}
