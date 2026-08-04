import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/guide/home_page_guide_scope.dart';
import 'package:reforge/features/home/ui/widgets/free_run_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/home_app_bar.dart';
import 'package:reforge/features/home/ui/widgets/home_workout_result_empty.dart';
import 'package:reforge/features/home/ui/widgets/home_workout_result_section.dart';
import 'package:reforge/features/home/ui/widgets/start_workout_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/home_workout_results_header.dart';
import 'package:reforge/features/workout_session/controllers/workout_restore_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    final guide = context.read<MainPageGuide?>();
    final guideIsRunning = context.select<GuideCubit, bool>(
      (cubit) => cubit.state is GuideRunning,
    );

    return SafeArea(
      top: false,
      bottom: false,
      child: MultiBlocListener(
        listeners: [
          // Once HomeCubit finishes initial loading, trigger the restore check.
          // This is a fire-and-forget: WorkoutRestoreCubit will emit
          // [WorkoutRestorePending] asynchronously if something is found.
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
            listener: (ctx, _) {
              unawaited(ctx.read<WorkoutRestoreCubit>().checkForInterrupted());
            },
          ),

          // Error toasts from HomeCubit.
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) => curr.error != null && prev.error != curr.error,
            listener: (ctx, state) {
              if (state.error != null) {
                toastification.showErrorToast(state.error!, ctx);
              }
            },
          ),
        ],
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadInitialData(),
              child: Skeletonizer(
                enabled: state.isLoading,
                child: CustomScrollView(
                  physics: guideIsRunning ? const NeverScrollableScrollPhysics() : null,
                  slivers: [
                    HomeSliverAppBar(
                      imageUrl: state.user?.avatarUrl,
                      username: state.user?.userName,
                    ),
                    SliverPadding(
                      padding: horizontalPadding.copyWith(top: 16, bottom: 16),
                      sliver: SliverToBoxAdapter(
                        child: Skeleton.replace(
                          replacement: const AvatarCardShimmer(),
                          child: _buildRankCard(
                            guide: guide,
                            rank: state.rank ?? RankEntity.mockWith(t),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: horizontalPadding.copyWith(bottom: 8),
                      sliver: SliverToBoxAdapter(
                        child: const StartWorkoutListTile().animateEntrance(),
                      ),
                    ),
                    if (Env.freeRunEnabled)
                      SliverPadding(
                        padding: horizontalPadding.copyWith(bottom: 32),
                        sliver: SliverToBoxAdapter(
                          child: const FreeRunListTile().animateEntrance(),
                        ),
                      ),
                    SliverPadding(
                      padding: horizontalPadding.copyWith(bottom: 16),
                      sliver: const WorkoutResultHeader(),
                    ),
                    BlocSelector<HomeCubit, HomeState, ({bool isStatsLoading, UserStats? currentStats})>(
                      selector: (state) => (
                        isStatsLoading: state.isStatsLoading,
                        currentStats: state.currentStats,
                      ),
                      builder: (context, state) {
                        final currentStats = state.isStatsLoading
                            ? UserStatsX.mock(badgeName: t.home.mockBadgeName)
                            : state.currentStats;

                        if (currentStats == null) {
                          return const HomeWorkoutResultEmpty();
                        } else {
                          return HomeWorkoutResultSection(
                            isLoading: state.isStatsLoading,
                            stats: currentStats,
                          );
                        }
                      },
                    ),
                    const AppBottomPaddingWidget.sliverWithAppBottomBarHeight(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankCard({
    required MainPageGuide? guide,
    required RankEntity rank,
  }) {
    final card = AvatarRankCard(rank: rank).animateEntrance();
    if (guide == null) return card;

    return GuideTarget(
      anchor: guide.anchor(MainPageGuideStep.characterEvolution),
      scope: homePageGuideScope,
      tooltip: guide.tooltip(MainPageGuideStep.characterEvolution),

      targetPadding: EdgeInsets.zero,
      child: card,
    );
  }
}
