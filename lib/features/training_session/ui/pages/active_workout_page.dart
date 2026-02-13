import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/router/routes.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/dynamic_workout_form.dart';

import 'package:reforge/features/training_session/controllers/workout_flow/workout_flow_cubit.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_section.dart';

import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class ActiveWorkoutPage extends StatelessWidget {
  const ActiveWorkoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
      builder: (context, exerciseState) {
        final programExercise = context.read<ActiveExerciseCubit>().programExercise;
        final exerciseDetails = programExercise.exerciseDetails;

        return PopScope(
          canPop: false,
          child: DefaultBackground(
            body: MultiBlocListener(
              listeners: [
                BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
                  listenWhen: (prev, curr) => !prev.isSubmitted && curr.isSubmitted,
                  listener: (context, state) async {
                    final flowCubit = context.read<WorkoutFlowCubit>();
                    final timerDuration = context.read<TimerCubit>().state.duration;

                    await flowCubit.nextExercise(timerDuration);
                  },
                ),
              ],
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  maxLength: 500,
                                  keyboardType: TextInputType.multiline,
                                  onChanged: context.read<ActiveExerciseCubit>().setNote,
                                ),
                              ),
                              WorkoutSection(exercise: exerciseDetails),
                              const SizedBox(height: 32),

                              BlocConsumer<ActiveExerciseCubit, ActiveExerciseState>(
                                listenWhen: (previous, current) =>
                                    previous.setValidationError != current.setValidationError,
                                listener: (context, state) {
                                  if (state.setValidationError == null) return;

                                  toastification.showErrorToast(state.setValidationError!, context);
                                },
                                builder: (context, state) {
                                  final cubit = context.read<ActiveExerciseCubit>();

                                  return DynamicWorkoutForm(
                                    metrics: exerciseDetails.metrics,
                                    system: state.measureSystem,
                                    isTiered: exerciseDetails.isTiered,
                                    tiers: exerciseDetails.tiers,

                                    selectedTier: state.selectedTier,

                                    sets: state.sets,
                                    onTierChanged: cubit.setTier,
                                    onAddSet: cubit.addSet,
                                    onUpdateSet: cubit.updateSet,
                                    onRemoveSet: cubit.removeSet,
                                    onDonePressed: cubit.markSetDone,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      if (exerciseDetails.metrics.any((m) => m == WorkoutMetric.distance)) ...[
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: t.workout.startRunning,
                          onPressed: () {
                            unawaited(const StartRunningPageRoute().push<void>(context));
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 8),
                      PrimaryButton(
                        text: t.workout.forgeNextMove,
                        onPressed: () async {
                          await context.read<ActiveExerciseCubit>().finishExercise();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loader: const Positioned.fill(child: ActiveWorkoutLoader()),
          ),
        );
      },
    );
  }
}

class ActiveWorkoutLoader extends StatelessWidget {
  const ActiveWorkoutLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActiveExerciseCubit, ActiveExerciseState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
