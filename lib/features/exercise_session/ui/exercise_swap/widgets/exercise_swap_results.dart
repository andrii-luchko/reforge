import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class ExerciseSwapResults extends StatelessWidget {
  const ExerciseSwapResults({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseSwapCubit, ExerciseSwapState>(
      builder: (context, state) {
        if (state.isLoading) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: state.query.isNotEmpty
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        t.workout.swapSearchLoadingQuery,
                        style: subheadH5Medium.copyWith(color: context.appTheme.beige600),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.exercises.isEmpty) {
          if (state.error != null) {
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    spacing: 16,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        t.errors.unexpected,
                        style: subheadH3Medium.copyWith(color: context.appTheme.beige600),
                        textAlign: TextAlign.center,
                      ),

                      PrimaryButton(
                        text: t.camera_detection.tryAgain,
                        onPressed: context.read<ExerciseSwapCubit>().retry,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                t.workout.noSwapExercises,
                style: subheadH3Medium.copyWith(color: context.appTheme.beige600),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: state.exercises.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == state.exercises.length) {
                return const PaginationLoader();
              }
              final exercise = state.exercises[index];
              return _ExerciseTile(
                exercise: exercise,
                isSelected: state.selectedExerciseId == exercise.id,
                isEnabled: !state.isSwapping,
              );
            },
          ),
        );
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.isSelected,
    required this.isEnabled,
  });

  final ExerciseDetailsEntity exercise;
  final bool isSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final tags = <String>[
      if (exercise.faction case final faction?) faction.name,
      ...exercise.metrics.map((metric) => metric.title(t, null)),
    ];
    return StaticWorkoutTile(
      title: exercise.name,
      description: exercise.description,
      imageUrl: exercise.thumbnailInstructionUrl,
      tags: tags,
      borderColor: isSelected ? context.appTheme.orange400 : null,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: isSelected ? const AppRadioButton(isSelected: true) : const SizedBox.shrink(),
      ),
      onTap: isEnabled ? () => context.read<ExerciseSwapCubit>().selectExercise(exercise.id) : null,
    );
  }
}
