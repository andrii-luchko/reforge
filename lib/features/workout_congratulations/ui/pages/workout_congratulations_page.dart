import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/achievement_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/congratulations_action_buttons.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/summary_content_widget.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutCongratulationsPage extends StatefulWidget {
  const WorkoutCongratulationsPage({super.key});

  @override
  State<WorkoutCongratulationsPage> createState() => _WorkoutCongratulationsPageState();
}

class _WorkoutCongratulationsPageState extends State<WorkoutCongratulationsPage> {
  late final WorkoutSessionSummaryEntity? _summary;
  late final double _xpProgress;
  var _milestoneIndex = 0;

  @override
  void initState() {
    super.initState();
    _summary = context.read<WorkoutFlowCubit>().state.summary;
    _xpProgress = _summary == null ? 0.2 : _calculateXpProgress(_summary);

    if (_summary case WorkoutSessionSummaryEntity(earnedMilestones: [final first, ...])) {
      _logMilestoneShown(first);
    }
  }

  double _calculateXpProgress(WorkoutSessionSummaryEntity summary) {
    final normalizedXp = summary.totalXpEarned.clamp(0, 500) / 500;
    final jitter = Random(summary.id).nextDouble() * 0.06;

    return (0.2 + normalizedXp * 0.44 + jitter).clamp(0.2, 0.7);
  }

  void _logMilestoneShown(UserWorkoutMilestoneEntity milestone) {
    unawaited(
      di.getIt<AnalyticsService>().logEvent(
        AnalyticsEvents.workoutBadgeEarned,
        {
          'milestone_id': milestone.id,
          'milestone_name': milestone.name,
          'tier': milestone.tier,
        },
      ),
    );
  }

  void _onAchievementNextPressed(WorkoutSessionSummaryEntity summary) {
    unawaited(
      di.getIt<AnalyticsService>().logEvent(
        AnalyticsEvents.workoutAchievementNextClick,
        {
          'milestone_index': _milestoneIndex,
          'total_milestones': summary.earnedMilestones.length,
        },
      ),
    );

    final nextIndex = _milestoneIndex + 1;
    setState(() => _milestoneIndex = nextIndex);

    if (nextIndex < summary.earnedMilestones.length) {
      _logMilestoneShown(summary.earnedMilestones[nextIndex]);
    }
  }

  void _onFinishPressed() {
    unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.workoutSummaryFinishClick));
    const HomePageRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    if (summary == null) return const SizedBox.shrink();

    final isShowingAchievement = _milestoneIndex < summary.earnedMilestones.length;

    return Scaffold(
      backgroundColor: context.appTheme.beige900,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: DefaultBackground(
        additionalAnimationsOnTop: const [
          Positioned.fill(child: ParticlesWidget()),
        ],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Spacer(),
                if (isShowingAchievement)
                  AchievementContentWidget(
                    key: ValueKey('achievement_$_milestoneIndex'),
                    milestone: summary.earnedMilestones[_milestoneIndex],
                  ).animateEntrance()
                else
                  SummaryContentWidget(
                    xpProgress: _xpProgress,
                    newLevel: summary.isLevelUp ? summary.currentLevel : null,
                    xpEarned: summary.totalXpEarned,
                    timeSpentSec: summary.duration,
                  ),
                const Spacer(),
                if (isShowingAchievement)
                  CongratulationsActionButtons(
                    shareContent: AchievementShareContent(
                      title: t.workout_congratulations.share_achievement_title,
                      description: t.workout_congratulations.share_achievement_message,
                      imageUrl: summary.earnedMilestones[_milestoneIndex].iconUrl,
                    ),
                    onNextPressed: () => _onAchievementNextPressed(summary),
                  )
                else
                  CongratulationsActionButtons(
                    shareContent: SummaryShareContent(
                      xpProgress: _xpProgress,
                      newLevel: summary.isLevelUp ? summary.currentLevel : null,
                      xpEarned: summary.totalXpEarned,
                      timeSpentSec: summary.duration,
                    ),
                    nextButtonText: t.common.finish_button,
                    onNextPressed: _onFinishPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
