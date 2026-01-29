import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/workout_common/models/workout_congratulations_content.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/achievement_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/rank_card_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/summary_content_widget.dart';
import 'package:reforge/features/workout_share/ui/widgets/share/share_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutCongratulationsPage extends StatefulWidget {
  const WorkoutCongratulationsPage({
    this.contentItems,
    this.defaultSummary,
    super.key,
  });

  /// List of content items to display (rank cards, achievements, etc.)
  final List<WorkoutCongratulationsContent>? contentItems;

  /// Default summary to show at the end (XP and time)
  final WorkoutSummaryContent? defaultSummary;

  @override
  State<WorkoutCongratulationsPage> createState() => _WorkoutCongratulationsPageState();
}

class _WorkoutCongratulationsPageState extends State<WorkoutCongratulationsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize cubit when page loads if content is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<WorkoutCongratulationsCubit>();
      final state = cubit.state;
      // Only initialize if cubit is in default state and we have content
      if (state.contentItems.isEmpty && widget.contentItems != null) {
        cubit.initialize(
          contentItems: widget.contentItems!,
          defaultSummary: widget.defaultSummary,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: DefaultBackground(
        body: WorkoutCongratulationsBody(),
        additionalAnimationsOnTop: [
          Positioned.fill(child: ParticlesWidget()),
        ],
      ),
    );
  }
}

class WorkoutCongratulationsBody extends StatelessWidget {
  const WorkoutCongratulationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const WorkoutCongratulationContent(),
            const Spacer(),
            BlocBuilder<WorkoutCongratulationsCubit, WorkoutCongratulationsState>(
              builder: (context, state) {
                final cubit = context.read<WorkoutCongratulationsCubit>();
                final currentContent = state.currentContent;
                final isShowingSummary = state.shouldShowSummary;
                final hasMore = state.hasNext || state.shouldShowSummary;

                return Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ShareButton(
                        shareContent: _buildShareContent(
                          currentContent,
                          isShowingSummary ? state.defaultSummary : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton(
                        text: hasMore ? t.common.next_button : t.common.finish_button,
                        onPressed: () {
                          if (hasMore) {
                            cubit.next();
                          } else {
                            const HomePageRoute().go(context);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareContent(
    WorkoutCongratulationsContent? content,
    WorkoutSummaryContent? summary,
  ) {
    if (content == null && summary != null) {
      return SummaryShareContent(content: summary);
    }

    if (content == null) {
      // Default summary share content
      return const SummaryShareContent(
        content: WorkoutSummaryContent(
          xpEarned: 0,
          timeSpent: Duration.zero,
        ),
      );
    }

    return switch (content) {
      RankCardCongratulations(:final content) => RankCardShareContent(content: content),
      AchievementCongratulations(:final content) => AchievementShareContent(content: content),
      SummaryCongratulations(:final content) => SummaryShareContent(content: content),
    };
  }
}

class WorkoutCongratulationContent extends StatelessWidget {
  const WorkoutCongratulationContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCongratulationsCubit, WorkoutCongratulationsState>(
      builder: (context, state) {
        final currentContent = state.currentContent;
        final isShowingSummary = state.shouldShowSummary;

        // Show summary if we've gone through all content items
        if (isShowingSummary && state.defaultSummary != null) {
          return SummaryContentWidget(content: state.defaultSummary!);
        }

        // Show current content item
        if (currentContent != null) {
          return switch (currentContent) {
            RankCardCongratulations(:final content) => RankCardContentWidget(content: content),
            AchievementCongratulations(:final content) => AchievementContentWidget(content: content),
            SummaryCongratulations(:final content) => SummaryContentWidget(content: content),
          };
        }

        // Fallback: default summary if no content at all
        return const SizedBox.shrink();
      },
    );
  }
}
