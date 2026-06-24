import 'package:flutter/widgets.dart';
// import 'package:reforge/features/workout_common/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_list_tile.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';

import 'package:reforge/features/workout_instruction/ui/widgets/instruction_section.dart';

class WorkoutSection extends StatelessWidget {
  const WorkoutSection({required this.exercise, super.key});

  final ExerciseDetailsEntity exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        ExpandableWorkoutTile(
          title: exercise.name,
          description: exercise.description,
          imageUrl: exercise.thumbnailInstructionUrl,
          children: [
            InstructionSection(
              needDecoration: false,
              steps: exercise.instructionsSteps,
            ),
          ],
        ),
        // const SizedBox(height: 16),
        // const AppTagsListView(tags: []),
      ],
    );
  }
}
