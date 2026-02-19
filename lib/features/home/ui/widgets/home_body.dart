import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/widgets/home_app_bar.dart';
import 'package:reforge/features/home/ui/widgets/home_workout_result_empty.dart';
import 'package:reforge/features/home/ui/widgets/home_workout_result_section.dart';
import 'package:reforge/features/home/ui/widgets/start_workout_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/home_workout_results_header.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) => current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            toastification.showErrorToast(state.error!, context);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadInitialData(),
            child: Skeletonizer(
              enabled: state.isLoading,
              child: CustomScrollView(
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
                        child: AvatarRankCard(
                          rank: state.rank ?? RankEntity.mockWith(t),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: horizontalPadding.copyWith(bottom: 16),
                    sliver: const SliverToBoxAdapter(
                      child: StartWorkoutListTile(),
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
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
