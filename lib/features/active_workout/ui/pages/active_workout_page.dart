import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/active_workout_page/active_workout_loader.dart';
import 'package:reforge/features/active_workout/ui/widgets/dynamic_workout_form.dart';
import 'package:reforge/features/active_workout/ui/widgets/exercise_results/previous_exercise_result_list_tile.dart';
import 'package:reforge/features/active_workout/ui/widgets/workout_section.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class ActiveWorkoutPage extends StatelessWidget {
  const ActiveWorkoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
          listenWhen: (prev, curr) => !prev.isSubmitted && curr.isSubmitted,
          listener: (context, state) async {
            final flowCubit = context.read<WorkoutFlowCubit>();
            final timerDuration = context.read<TimerCubit>().state.duration;

            await flowCubit.nextExercise(timerDuration);
          },
        ),

        BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
          listenWhen: (previous, current) => previous.setValidationError != current.setValidationError,
          listener: (context, state) {
            if (state.setValidationError == null) return;
            toastification.showErrorToast(state.setValidationError!, context);
          },
        ),
      ],
      child: BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
        builder: (context, exerciseState) {
          final cubit = context.read<ActiveExerciseCubit>();
          final programExercise = cubit.programExercise;
          final exerciseDetails = programExercise.exerciseDetails;
          final previousResult = exerciseState.previousResult;

          return DefaultBackground(
            body: Skeletonizer(
              enabled: exerciseState.isLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
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
                                  maxLength: exerciseState.showNotesLimit ? exerciseState.notesLimit : null,
                                  keyboardType: TextInputType.multiline,
                                  onChanged: context.read<ActiveExerciseCubit>().setNote,
                                ),
                              ),

                              WorkoutSection(exercise: exerciseDetails),
                              const SizedBox(height: 24),

                              if (previousResult != null) ...[
                                PreviousExerciseResultListTile(
                                  result: previousResult,
                                  system: exerciseState.measureSystem,
                                ),
                                const SizedBox(height: 32),
                              ],

                              DynamicWorkoutForm(
                                metrics: exerciseDetails.metrics,
                                system: exerciseState.measureSystem,
                                isTiered: exerciseDetails.isTiered,
                                tiers: exerciseDetails.tiers,

                                selectedTier: exerciseState.selectedTier,

                                sets: exerciseState.sets,
                                onTierChanged: cubit.setTier,
                                onAddSet: cubit.addSet,
                                onUpdateSet: cubit.updateSet,
                                onRemoveSet: cubit.removeSet,
                                onDonePressed: cubit.markSetDone,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Skeleton.leaf(
                        child: Row(
                          spacing: 8,
                          children: [
                            if (exerciseDetails.poseDetectionPreset != null)
                              AppIconButton(
                                iconAsset: Assets.images.icons.cameraAlt,
                                iconSize: 20,
                                onPressed: () => CameraDetectionPageRoute($extra: cubit).push<void>(context),
                              ),
                            Expanded(
                              child: PrimaryButton(
                                text: t.workout.forgeNextMove,
                                onPressed: () async {
                                  await context.read<ActiveExerciseCubit>().finishExercise();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loader: const Positioned.fill(child: ActiveWorkoutLoader()),
          );
        },
      ),
    );
  }
}
