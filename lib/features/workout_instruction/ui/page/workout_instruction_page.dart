import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_common/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/exercise_description_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/instruction_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/video_section.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';

import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class WorkoutInstructionPage extends StatelessWidget {
  const WorkoutInstructionPage({required this.name, required this.workoutId, super.key});

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      body: DefaultBackground(
        body: WorkoutInstructionBody(
          name: name,
          workoutId: workoutId,
        ),
      ),
    );
  }
}

class WorkoutInstructionBody extends StatelessWidget {
  const WorkoutInstructionBody({
    required this.name,
    required this.workoutId,
    super.key,
  });

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutFlowCubit, WorkoutFlowState>(
      builder: (context, state) {
        final programDay = state.programDay;

        final exercise = programDay?.sortedExercises
            .map((e) => e.exerciseDetails)
            .firstWhereOrNull((e) => e.id == workoutId);

        if (programDay == null || exercise == null) {
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
                    videoUrl: exercise.videoInstructionUrl,
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
                    description: exercise.description,
                  ),
                ),
              ),
              SliverPadding(
                padding: const .symmetric(horizontal: 16, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: InstructionSection(
                    steps: exercise.instructionsSteps,
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
