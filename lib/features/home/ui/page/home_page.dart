import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/widgets/home_app_bar.dart';
import 'package:reforge/features/home/ui/widgets/start_workout_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/activity_section.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/badge_list_tile.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/home_workout_results_header.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit cubit = context.read<HomeCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(cubit.loadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: const HomeBody(),

        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.home(color: appTheme.orange500),
          ),
        ],
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Skeletonizer(
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
                        rank: state.rank ?? RankEntity.mock(),
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
                SliverPadding(padding: horizontalPadding.copyWith(bottom: 16), sliver: const WorkoutResultHeader()),

                BlocSelector<HomeCubit, HomeState, ({bool isStatsLoading, UserStats? currentStats})>(
                  selector: (state) => (isStatsLoading: state.isStatsLoading, currentStats: state.currentStats),
                  builder: (context, state) {
                    final currentStats = state.isStatsLoading ? UserStatsX.mock() : state.currentStats;
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
          );
        },
      ),
    );
  }
}

class HomeWorkoutResultEmpty extends StatelessWidget {
  const HomeWorkoutResultEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        children: [Text('empty data')],
      ),
    );
  }
}

class HomeWorkoutResultSection extends StatelessWidget {
  const HomeWorkoutResultSection({
    required this.isLoading,
    required this.stats,
    super.key,
  });

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  final bool isLoading;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    return SliverSkeletonizer(
      enabled: isLoading,
      child: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: BadgeListTile(
                leadingIcon: AppSvgListTileIcon(
                  asset: Assets.images.icons.lock,
                  color: context.appTheme.beige100,
                ),
                title: stats.badgeName ?? 'No badge yet',
                subtitle: 'Badge earned',
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: XpTile(
                currentXp: stats.currentXp,
                totalXp: stats.totalXp,
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ActivitySection(
                stats: stats,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
