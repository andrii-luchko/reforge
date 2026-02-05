import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';

import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leaderboard_top_card.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UsersLeaderboardSlivers extends StatelessWidget {
  const UsersLeaderboardSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersLeaderboardCubit, UsersLeaderboardState>(
      builder: (context, state) {
        final cubit = context.read<UsersLeaderboardCubit>();
        final currentUsers = state.currentUsersList;
        final isLoading = state.isLoading;
        final isPaginationLoading = state.isPaginationLoading;

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
              // 1. Faction Filter
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Skeleton.leaf(
                      child: MultiOptionSwitcher<Faction>(
                        selectedValue: state.selectedFaction,
                        values: Faction.values,
                        labelBuilder: (value) => value.title(t),
                        onSelected: cubit.changeFaction,
                        borderRadius: BorderRadius.circular(50),
                        padding: const EdgeInsets.all(3),
                        itemTextStyle: subheadH5Medium.copyWith(color: context.appTheme.beige100),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Top 3 Card (Immortal Forces)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Skeleton.replace(
                      replacement: const ImmortalForcesCardShimmer(),
                      child: ImmortalForcesCard(
                        users: currentUsers,
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                    ),
                  ),
                ),
              ),

              // 3. Header "Leaderboard List"
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Leaderboard list',
                      style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                    ),
                  ),
                ),
              ),

              // 4. The List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: LeaderBoardUsersList(
                  users: currentUsers,
                  currentUserIndex: state.currentUserIndex,
                ),
              ),

              if (isPaginationLoading)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: ScreenLoadingIndicator(padding: EdgeInsets.all(16)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
