import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/workout_section.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/ui/widgets/running_laps_list.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:toastification/toastification.dart';

class RunningLapsSummaryPage extends StatelessWidget {
  const RunningLapsSummaryPage({required this.onExerciseFinished, super.key});

  final Future<void> Function() onExerciseFinished;

  @override
  Widget build(BuildContext context) {
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
          final exerciseDetails = activeExerciseCubit.effectiveExercise;

          final measureSystem = activeExerciseCubit.state.measureSystem;

          final completedLaps = activeExerciseCubit.state.sets.where((set) => set.isDone).map((set) {
            final segment = set.programSegmentId == null
                ? null
                : cubit.config.segments.firstWhereOrNull((segment) => segment.id == set.programSegmentId);

            final distanceM = (set.distance ?? 0) * 1000;
            final speedKmH = set.pace ?? 0;

            return ExerciseLap(
              lapNumber: set.setNumber ?? 0,
              distanceMeters: distanceM,
              durationSeconds: set.time?.inSeconds ?? 0,
              avgSpeedKmH: speedKmH,
              currentSpeedKmH: 0,
              avgPaceMinKm: speedKmH > 0 ? 60.0 / speedKmH : 0,
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
                                initialValue: context.read<ActiveExerciseCubit>().state.notes,
                                onChanged: context.read<ActiveExerciseCubit>().setNote,
                              ),
                            ),

                            WorkoutSection(exercise: exerciseDetails),
                            const SizedBox(height: 16),

                            RunningLapsList(
                              laps: completedLaps,
                              system: measureSystem,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    RunningSummaryFooter(
                      state: state,
                      onBackToRunning: cubit.goToActive,
                      onFinishExercise: state.isSubmitting || activeExerciseCubit.state.isSendingSet
                          ? null
                          : () => unawaited(_onFinishExercise(context, cubit)),
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

  Future<void> _onFinishExercise(BuildContext context, RunningTrackerCubit cubit) async {
    await onExerciseFinished();
    if (!context.mounted || !context.read<ActiveExerciseCubit>().state.isSubmitted) return;

    await cubit.finishExercise();
  }
}

class RunningSummaryFooter extends StatelessWidget {
  const RunningSummaryFooter({
    required this.state,
    required this.onBackToRunning,
    required this.onFinishExercise,
    super.key,
  });

  final RunningTrackerState state;
  final VoidCallback onBackToRunning;
  final VoidCallback? onFinishExercise;

  @override
  Widget build(BuildContext context) {
    final terminalFailure = state.terminalFailure;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (terminalFailure != null) ...[
          Container(
            key: const ValueKey('running_terminal_failure'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appTheme.red400.withValues(alpha: 0.12),
              border: Border.all(color: context.appTheme.red400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: context.appTheme.red400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    terminalFailure.message,
                    style: bodyLRegular.copyWith(color: context.appTheme.beige100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.canReturnToActive) ...[
          SecondaryButton(
            text: t.running.summary.back_to_running,
            onPressed: onBackToRunning,
          ),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          text: t.running.summary.finish_exercise,
          onPressed: onFinishExercise,
        ),
      ],
    );
  }
}
