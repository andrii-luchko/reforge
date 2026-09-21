import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/models/exercise_instruction_args.dart';
import 'package:reforge/features/workout_program/ui/widgets/exercise_list_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class ExerciseSection extends StatelessWidget {
  const ExerciseSection({
    required this.exercises,
    super.key,
  });

  final List<ExerciseInstructionArgs> exercises;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: Text(
            t.workout_details.exercise_count(n: exercises.length),
            style: subheadH2Medium.copyWith(color: appTheme.beige100),
          ),
        ),
        ExerciseListView(
          exercises: exercises,
        ),
      ],
    );
  }
}
