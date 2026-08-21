import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/di/service_injector.dart';
import 'package:reforge/app/utils/extensions/duration_extensions.dart';
import 'package:reforge/app/utils/helpers/keyboard_visibility_provider.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/workout_section.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/controller/map/running_map_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/ui/widgets/active_running_map_container.dart';
import 'package:reforge/features/running/ui/widgets/recommended_speed_hint.dart';
import 'package:reforge/features/running/ui/widgets/running_metrics_panel.dart';
import 'package:reforge/features/running/ui/widgets/treadmill_speed_stepper.dart';
import 'package:reforge/features/running/ui/widgets/walk_audio_hint_dialog.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/animate_visibility.dart';
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

            final cubit = context.read<RunningTrackerCubit>();

            final segment = cubit.config.segments.elementAtOrNull(state.currentSegmentIndex);

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

                    .treadmill => const Expanded(
                      child: ActiveTreadmillSession(),
                    ),

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
                    return AnimatedVisibility(
                      isVisible: !KeyboardVisibilityProvider.isKeyboardVisible(context),
                      child: _ActionButtons(state: state, cubit: cubit),
                    );
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
        final currentSegment = context.read<RunningTrackerCubit>().currentSegment;

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
                      paceMinKm: 0,
                      system: measureSystem,
                    ),
            ),

            AnimatedSize(
              duration: Durations.short3,
              child: currentSegment?.recommendedSpeed != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      child: RecommendedSpeedHint(recommendedSpeed: currentSegment!.recommendedSpeed!),
                    )
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: Stack(
                children: [
                  BlocProvider(
                    create: (context) => getIt<RunningMapCubit>(
                      param1: context.read<RunningTrackerCubit>().config,
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
                        ignoring: currentSegment != null,
                        child: AnimatedOpacity(
                          opacity: currentSegment != null ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: CurrentPhaseHint(
                            measureSystem: measureSystem,
                            segment: currentSegment!,
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

class ActiveTreadmillSession extends StatelessWidget {
  const ActiveTreadmillSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final measureSystem = context.read<ActiveExerciseCubit>().state.measureSystem;

    return BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
      builder: (context, state) {
        final exerciseDetails = context.read<ActiveExerciseCubit>().effectiveExercise;

        final lap = state.currentLap;
        final currentSegment = context.read<RunningTrackerCubit>().currentSegment;

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
                  paceMinKm: 0,
                  system: measureSystem,
                ),

              AnimatedSize(
                duration: Durations.short3,
                child: currentSegment?.recommendedSpeed != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: RecommendedSpeedHint(
                          recommendedSpeed: currentSegment!.recommendedSpeed!,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              TreadmillSpeedStepper(
                speedKmH: state.treadmillSpeedKmH ?? RunningTrackerCubit.defaultTreadmillSpeedKmH,
                measureSystem: measureSystem,
                enabled: state.canControlTracking && !state.isSubmitting,
                onChangedKmH: context.read<RunningTrackerCubit>().setTreadmillSpeedKmH,
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
                opacity: !state.isPaused && currentSegment != null ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: CurrentPhaseHint(
                  measureSystem: measureSystem,
                  segment: currentSegment!,
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

class CurrentPhaseHint extends StatelessWidget {
  const CurrentPhaseHint({required this.measureSystem, required this.segment, super.key});

  final ExerciseSegmentEntity segment;
  final MeasurementSystem measureSystem;

  @override
  Widget build(BuildContext context) {
    final target = _formatTarget(segment);

    return AppTag(
      text: '${segment.activity.title}  · ${target ?? ''}',

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  String? _formatTarget(ExerciseSegmentEntity segment) {
    return switch (segment.targetMetric) {
      WorkoutMetric.time => Duration(seconds: segment.durationSec).toDigital(),
      WorkoutMetric.distance => _formatDistance(segment.distanceM, measureSystem),
      _ => null,
    };
  }

  String _formatDistance(double meters, MeasurementSystem system) {
    if (system == MeasurementSystem.imperial) {
      final miles = MeasureSystemValues.toMiles(meters / 1000);
      final value = miles == miles.roundToDouble()
          ? miles.toInt().toString()
          : miles < 1
          ? miles.toStringAsFixed(2)
          : miles.toStringAsFixed(1);
      return '$value ${t.measure_system.distance.imperial_symbol}';
    }

    if (meters >= 1000) {
      final kilometers = meters / 1000;
      final value = kilometers == kilometers.roundToDouble()
          ? kilometers.toInt().toString()
          : kilometers.toStringAsFixed(1);
      return '$value km';
    }

    final value = meters == meters.roundToDouble() ? meters.toInt().toString() : meters.toStringAsFixed(1);
    return '$value m';
  }
}
