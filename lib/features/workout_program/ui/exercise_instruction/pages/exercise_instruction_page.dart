import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/exercise_description_section.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/instruction_section.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/video_section.dart';
import 'package:reforge/features/workout_program/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class ExerciseInstructionPage extends StatelessWidget {
  const ExerciseInstructionPage({
    required this.name,
    required this.workoutId,
    this.exercise,
    super.key,
  });

  final String name;
  final int workoutId;
  final ExerciseDetailsEntity? exercise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      body: DefaultBackground(
        body: ExerciseInstructionBody(
          name: name,
          workoutId: workoutId,
          exercise: exercise,
        ),
      ),
    );
  }
}

class ExerciseInstructionBody extends StatelessWidget {
  const ExerciseInstructionBody({
    required this.name,
    required this.workoutId,
    this.exercise,
    super.key,
  });

  final String name;
  final int workoutId;
  final ExerciseDetailsEntity? exercise;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        final programDay = state.programDay;

        final resolvedExercise =
            exercise ??
            programDay?.sortedExercises.map((e) => e.exerciseDetails).firstWhereOrNull((e) => e.id == workoutId);

        if (resolvedExercise == null) {
          return const ScreenLoadingIndicator();
        }
        return SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              DefaultSliverAppBar(onPressed: Navigator.of(context).pop, title: name),
              SliverPadding(
                padding: const .symmetric(horizontal: 16, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: VideoSection(
                    videoUrl: resolvedExercise.videoInstructionUrl,
                  ),
                ),
              ),
              const SliverPadding(
                padding: .symmetric(horizontal: 16, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: AppTagsListView(tags: []),
                ),
              ),
              SliverPadding(
                padding: const .symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: ExerciseDescriptionSection(
                    description: resolvedExercise.description,
                  ),
                ),
              ),
              SliverPadding(
                padding: const .symmetric(horizontal: 16, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: InstructionSection(
                    steps: resolvedExercise.instructionsSteps,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
