import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/features/workout_instruction/data/repositories/mock_exercises.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/exercise_description_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/instruction_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/video_section.dart';

import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutInstructionPage extends StatelessWidget {
  const WorkoutInstructionPage({required this.name, required this.workoutId, super.key});

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              name,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: DefaultBackground(
        body: WorkoutInstructionBody(
          workoutId: workoutId,
        ),
      ),
    );
  }
}

class WorkoutInstructionBody extends StatelessWidget {
  const WorkoutInstructionBody({
    required this.workoutId,
    super.key,
  });

  final int workoutId;

  @override
  Widget build(BuildContext context) {
    final exercise = mockExercises.firstWhere((e) => e.id == workoutId);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              VideoSection(
                videoUrl: exercise.videoUrl,
              ),
              const SizedBox(height: 16),

              const AppTagsListView(tags: ['10 reps', 'xp 1200', 'Duration 15 min']),

              const SizedBox(height: 32),
              ExerciseDescriptionSection(
                description: exercise.description,
              ),
              const SizedBox(height: 32),
              InstructionSection(
                steps: exercise.instructionSteps,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
