import 'package:flutter/widgets.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/instruction_section.dart';
// import 'package:reforge/features/workout_program/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutSection extends StatelessWidget {
  const WorkoutSection({
    required this.exercise,
    this.coachNote,
    super.key,
  });

  final ExerciseDetailsEntity exercise;
  final String? coachNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        ExpandableWorkoutTile(
          title: exercise.name,
          description: exercise.description,
          imageUrl: exercise.thumbnailInstructionUrl,
          tags: exercise.availableTags(t),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: InstructionSection(
                needDecoration: false,
                steps: exercise.instructionsSteps,
                coachNote: coachNote,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 16),
        // const AppTagsListView(tags: []),
      ],
    );
  }
}
