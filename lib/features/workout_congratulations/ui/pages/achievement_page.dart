import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/achievement_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/congratulations_action_buttons.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutAchievementPage extends StatefulWidget {
  const WorkoutAchievementPage({
    required this.milestoneIndex,
    super.key,
  });

  final int milestoneIndex;

  @override
  State<WorkoutAchievementPage> createState() => _WorkoutAchievementPageState();
}

class _WorkoutAchievementPageState extends State<WorkoutAchievementPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCongratulationsCubit>();
    final workoutResult = cubit.state.workoutResult;
    if (workoutResult != null) {
      final milestones = workoutResult.earnedMilestones;
      final index = widget.milestoneIndex;
      if (index >= 0 && index < milestones.length) {
        final milestone = milestones[index];
        unawaited(di.getIt<AnalyticsService>().logEvent(
          AnalyticsEvents.workoutBadgeEarned,
          {
            'milestone_id': milestone.id,
            'milestone_name': milestone.name,
            'tier': milestone.tier,
          },
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutCongratulationsCubit>();
    final workoutResult = cubit.state.workoutResult;

    if (workoutResult == null) return const SizedBox.shrink();

    final milestones = workoutResult.earnedMilestones;
    if (widget.milestoneIndex < 0 || widget.milestoneIndex >= milestones.length) {
      return const SizedBox.shrink();
    }

    final milestone = milestones[widget.milestoneIndex];

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
                unawaited(di.getIt<AnalyticsService>().logEvent(
                  AnalyticsEvents.workoutAchievementNextClick,
                  {
                    'milestone_index': widget.milestoneIndex,
                    'total_milestones': milestones.length,
                  },
                ));
                cubit.onNextPressed(currentMilestoneIndex: widget.milestoneIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}
