import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_common/ui/widgets/exercise_list_view.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';

class ExerciseSection extends StatelessWidget {
  const ExerciseSection({
    required this.exercises,
    super.key,
  });

  final List<ExerciseDetailsEntity> exercises;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: Text(
            '${exercises.length} Exercises',
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
