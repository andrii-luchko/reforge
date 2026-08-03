import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/helpers/keyboard_visibility_provider.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/active_exercise_loader.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/dynamic_workout_form.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_results/previous_exercise_result_list_tile.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_swap_button.dart';

import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/workout_section.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RegularExercisePage extends StatelessWidget {
  const RegularExercisePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);

    return BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
      builder: (context, exerciseState) {
        final cubit = context.read<ActiveExerciseCubit>();
        final exerciseDetails = exerciseState.effectiveExercise;
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
                                initialValue: exerciseState.notes,
                                hintText: t.workout.addNotesHint,
                                maxLines: null,
                                maxLength: exerciseState.showNotesLimit ? exerciseState.notesLimit : null,
                                keyboardType: TextInputType.multiline,
                                onChanged: context.read<ActiveExerciseCubit>().setNote,
                              ),
                            ),

                            WorkoutSection(exercise: exerciseDetails),
                            const SizedBox(height: 12),
                            const ExerciseSwapButton(),
                            const SizedBox(height: 24),

                            if (previousResult != null && previousResult.sets.isNotEmpty) ...[
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
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      child: isKeyboardVisible
                          ? const SizedBox.shrink()
                          : AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 150),
                              child: RegularExerciseFooter(
                                isPoseDetectionEnabled: exerciseDetails.poseDetectionPreset != null,
                                onCameraButtonPressed: () =>
                                    CameraDetectionPageRoute($extra: cubit).push<void>(context),
                                onPrimaryButtonPressed: () async {
                                  await context.read<ActiveExerciseCubit>().finishExercise();
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          loader: const Positioned.fill(child: ActiveExerciseLoader()),
        );
      },
    );
  }
}

class RegularExerciseFooter extends StatelessWidget {
  const RegularExerciseFooter({
    required this.isPoseDetectionEnabled,
    required this.onPrimaryButtonPressed,
    this.onCameraButtonPressed,
    super.key,
  });

  final bool isPoseDetectionEnabled;

  final VoidCallback onPrimaryButtonPressed;
  final VoidCallback? onCameraButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Row(
          spacing: 8,
          children: [
            if (isPoseDetectionEnabled)
              AppIconButton(
                iconAsset: Assets.images.icons.cameraAlt,
                iconSize: 20,
                onPressed: onCameraButtonPressed,
              ),
            Expanded(
              child: PrimaryButton(
                text: t.workout.forgeNextMove,
                onPressed: onPrimaryButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
