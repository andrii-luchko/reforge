import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/achievement_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/congratulations_action_buttons.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutAchievementPage extends StatelessWidget {
  const WorkoutAchievementPage({
    required this.milestoneIndex,
    super.key,
  });

  final int milestoneIndex;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutCongratulationsCubit>();
    final workoutResult = cubit.state.workoutResult;

    if (workoutResult == null) return const SizedBox.shrink();

    final milestones = workoutResult.earnedMilestones;
    if (milestoneIndex < 0 || milestoneIndex >= milestones.length) {
      return const SizedBox.shrink();
    }

    final milestone = milestones[milestoneIndex];

    //final isLastMilestone = milestoneIndex == milestones.length - 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Spacer(),
            AchievementContentWidget(milestone: milestone),
            const Spacer(),
            CongratulationsActionButtons(
              shareContent: AchievementShareContent(
                title: t.workout_congratulations.share_achievement_title,
                description: t.workout_congratulations.share_achievement_message,
                imageUrl: milestone.iconUrl,
              ),
              onNextPressed: () {
                cubit.onNextPressed(currentMilestoneIndex: milestoneIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}
