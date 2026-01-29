import 'package:flutter/material.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_dialogs.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class PreviousExerciseResultListTile extends StatelessWidget {
  const PreviousExerciseResultListTile({required this.result, required this.system, super.key});
  final PreviousExerciseResult result;
  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leadingIcon: AppIconButton(
        iconAsset: Assets.images.icons.dumbbell,
      ),
      title: 'Previous achievements',
      subtitle: 'Your past highlights',
      onTap: () async {
        await WorkoutDialogs.pastResultsDialog(context, result, system);
      },
    );
  }
}
