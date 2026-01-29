import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/workout_common/models/exercise_details.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_list_tile.dart';

class ExerciseListView extends StatelessWidget {
  const ExerciseListView({required this.exercises, super.key});

  final List<ExerciseDetails> exercises;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final exercise = exercises[index];

        return StaticWorkoutTile(
          title: exercise.name,
          description: exercise.description,
          imageUrl: exercise.thumbnailInstructionUrl,
          // tags: exercise.,
          onTap: () async {
            await WorkoutInstructionPageRoute(
              name: exercise.name,
              workoutId: exercise.id,
              // ignore: inference_failure_on_function_invocation
            ).push(context);
          },
        );
      },
    );
  }
}
