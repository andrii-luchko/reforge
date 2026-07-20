// ignore_for_file: comment_references

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/exercise_results/previous_exercise_result_list_tile.dart';
import 'package:reforge/features/active_workout/ui/widgets/workout_section.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/ui/widgets/audio_hint_dialog.dart';
import 'package:reforge/features/running/ui/widgets/running_mode_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:toastification/toastification.dart';

/// First screen of the running exercise flow.
///
/// Mirrors [ActiveWorkoutPage] in structure but replaces [DynamicWorkoutForm]
/// with a "Start Running" button. The notes and exercise detail sections are
/// shared between both exercise types.
///
/// Pressing "Start Running" opens [RunningModeDialog] which handles the
/// mode selection, countdown, and eventually [RunningTrackerCubit.startLap].
class RunningOverviewPage extends StatelessWidget {
  const RunningOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RunningTrackerCubit, RunningTrackerState>(
          listenWhen: (prev, curr) => curr.phase == .overview && prev.error != curr.error,
          listener: (context, state) {
            if (state.error case final err?) {
              toastification.showErrorToast(err, context);
            }
          },
        ),
        BlocListener<RunningTrackerCubit, RunningTrackerState>(
          listenWhen: (prev, curr) => curr.phase == .overview && prev.mode == null && curr.mode != null,

          listener: (context, state) async {
            final runningCubit = context.read<RunningTrackerCubit>();

            await runningCubit.askPermissions();
          },
        ),

        BlocListener<RunningTrackerCubit, RunningTrackerState>(
          listenWhen: (previous, current) =>
              current.phase == .overview &&
              !current.isPaused &&
              !previous.isPermissionGranted &&
              current.isPermissionGranted,

          listener: (context, state) async {
            final runningCubit = context.read<RunningTrackerCubit>();
            unawaited(runningCubit.warmUpTracking());

            if (context.mounted) {
              if (!runningCubit.hasSeenAudioHint) {
                await AudioHintDialog.show(context);
                await runningCubit.markAudioHintSeen();
              }

              if (context.mounted) {
                final started = await const StartRunningPageRoute().push<bool>(context);

                if (started ?? false) {
                  await runningCubit.startLap();
                } else {
                  runningCubit.cancelStart();
                }
              }
            }
          },
        ),
      ],
      child: BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
        builder: (context, runningState) {
          final cubit = context.read<RunningTrackerCubit>();
          final programExercise = cubit.programExercise;
          final exerciseDetails = programExercise.exerciseDetails;

          final activeExerciseCubit = context.read<ActiveExerciseCubit>();

          final previousResult = activeExerciseCubit.state.previousResult;
          final measureSystem = activeExerciseCubit.state.measureSystem;

          return DefaultBackground(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: AppTextField(
                                initialValue: context.read<ActiveExerciseCubit>().state.notes,
                                hintText: t.workout.addNotesHint,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: context.read<ActiveExerciseCubit>().setNote,
                              ),
                            ),

                            WorkoutSection(exercise: exerciseDetails),
                            const SizedBox(height: 24),

                            if (previousResult != null) ...[
                              PreviousExerciseResultListTile(
                                result: previousResult,
                                system: measureSystem,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: t.workout.startRunning,
                      onPressed: () async {
                        final mode = await RunningModeDialog.show(context);

                        if (mode != null) {
                          cubit.setMode(mode);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
