import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/workout_section.dart';
import 'package:reforge/features/running/controller/map/running_map_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/ui/widgets/active_running_map_container.dart';
import 'package:reforge/features/running/ui/widgets/audio_hint_dialog.dart';
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
    return MultiBlocListener(
      listeners: [
        BlocListener<RunningTrackerCubit, RunningTrackerState>(
          listenWhen: (prev, curr) => prev.error != curr.error,
          listener: (context, state) {
            if (state.error case final err?) {
              toastification.showErrorToast(err, context);
            }
          },
        ),
        BlocListener<RunningTrackerCubit, RunningTrackerState>(
          listenWhen: (prev, curr) => curr.phase == .active && curr.lapJustCompleted && !prev.lapJustCompleted,
          listener: (context, state) async {
            // state.currentSegmentIndex is already the NEW active segment index.
            // The segment that just finished = currentSegmentIndex - 1.

            logger.d(state.currentSegmentIndex);
            final cubit = context.read<RunningTrackerCubit>();
            final programExercise = cubit.programExercise;

            final segment = programExercise.segments.elementAtOrNull(state.currentSegmentIndex);

            if (segment != null && segment.activity == .walk) {
              await WalkAudioHintDialog.show(context, Duration(seconds: segment.durationSec));
            }

            cubit.clearLapCompleted();
          },
        ),
      ],
      child: DefaultBackground(
        body: SafeArea(
          child: Column(
            children: [
              BlocSelector<RunningTrackerCubit, RunningTrackerState, RunningMode?>(
                selector: (state) => state.mode,
                builder: (context, mode) {
                  return switch (mode) {
                    .gps => const Expanded(child: ActiveGpsSession()),

                    .pedometer => const Expanded(child: ActivePedometerSession()),

                    _ => Container(),
                  };
                },
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
                  builder: (context, state) {
                    final cubit = context.read<RunningTrackerCubit>();
                    return _ActionButtons(state: state, cubit: cubit);
                  },
                ),
              ),
            ],
          ),
        ),
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
              text: t.running.active.finish,
              onPressed: () async {
                await cubit.endWorkout();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: t.running.active.resume,
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
            text: t.running.active.next_lap,
            onPressed: state.isSubmitting ? null : () async => cubit.forceNextLap(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            text: t.running.active.pause,
            onPressed: cubit.pauseLap,
          ),
        ),
      ],
    );
  }
}

class ActiveGpsSession extends StatelessWidget {
  const ActiveGpsSession({super.key});

  @override
  Widget build(BuildContext context) {
    final measureSystem = context.read<ActiveExerciseCubit>().state.measureSystem;

    return BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
      builder: (context, state) {
        final lap = state.currentLap;
        final segmentActivity = lap?.activity;

        return Column(
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
                      speedKmH: 0,

                      system: measureSystem,
                    ),
            ),

            Expanded(
              child: Stack(
                children: [
                  BlocProvider(
                    create: (context) => getIt<RunningMapCubit>(
                      param1: context.read<RunningTrackerCubit>().workoutSessionId,
                      param2: context.read<RunningTrackerCubit>().programExercise.id,
                      // ignore: discarded_futures
                    )..init(),
                    child: const ActiveRunningMapContainer(),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: IgnorePointer(
                      ignoring: !state.isPaused,
                      child: AnimatedOpacity(
                        opacity: state.isPaused ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: AppTag(
                          text: t.running.active.paused,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  if (!state.isPaused)
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: IgnorePointer(
                        ignoring: segmentActivity == .walk,
                        child: AnimatedOpacity(
                          opacity: segmentActivity == .walk ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: AppTag(
                            text: t.running.active.walk,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ActivePedometerSession extends StatelessWidget {
  const ActivePedometerSession({super.key});

  @override
  Widget build(BuildContext context) {
    final measureSystem = context.read<ActiveExerciseCubit>().state.measureSystem;

    return BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
      builder: (context, state) {
        final cubit = context.read<RunningTrackerCubit>();
        final programExercise = cubit.programExercise;
        final exerciseDetails = programExercise.exerciseDetails;

        final lap = state.currentLap;
        final segmentActivity = lap?.activity;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppTextField(
                  hintText: t.workout.addNotesHint,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  initialValue: context.read<ActiveExerciseCubit>().state.notes,
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
                  speedKmH: 0,

                  system: measureSystem,
                ),

              const SizedBox(height: 32),
              AnimatedOpacity(
                opacity: state.isPaused ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: state.isPaused
                    ? AppTag(
                        text: t.running.active.paused,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      )
                    : const SizedBox.shrink(),
              ),

              AnimatedOpacity(
                opacity: !state.isPaused && segmentActivity == .walk ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: AppTag(
                  text: t.running.active.walk,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
