import 'package:flutter/material.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/exercise_description_section.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/instruction_section.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/video_section.dart';
import 'package:reforge/features/workout_program/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class ExerciseInstructionPage extends StatelessWidget {
  const ExerciseInstructionPage({
    required this.exercise,
    this.coachNote,
    super.key,
  });

  final ExerciseDetailsEntity exercise;
  final String? coachNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      body: DefaultBackground(
        body: ExerciseInstructionBody(
          exercise: exercise,
          coachNote: coachNote,
        ),
      ),
    );
  }
}

class ExerciseInstructionBody extends StatelessWidget {
  const ExerciseInstructionBody({
    required this.exercise,
    this.coachNote,
    super.key,
  });

  final ExerciseDetailsEntity exercise;
  final String? coachNote;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          DefaultSliverAppBar(onPressed: Navigator.of(context).pop, title: exercise.name),
          SliverPadding(
            padding: const .symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: VideoSection(
                videoUrl: exercise.videoInstructionUrl,
              ),
            ),
          ),
          SliverPadding(
            padding: const .only(left: 16, right: 16, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: AppTagsListView(tags: exercise.availableTags(t)),
            ),
          ),
          SliverPadding(
            padding: const .only(left: 16, right: 16, bottom: 16, top: 16),
            sliver: SliverToBoxAdapter(
              child: ExerciseDescriptionSection(
                description: exercise.description,
              ),
            ),
          ),
          SliverPadding(
            padding: const .only(left: 16, right: 16, top: 16),
            sliver: AppBottomPaddingWidget.sliver(
              extraSpace: 0,
              child: SliverToBoxAdapter(
                child: InstructionSection(
                  steps: exercise.instructionsSteps,
                  coachNote: coachNote,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
