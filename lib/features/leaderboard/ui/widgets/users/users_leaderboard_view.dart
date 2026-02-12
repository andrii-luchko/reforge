import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/immortal_forges_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class UsersLeaderboardSlivers extends StatelessWidget {
  const UsersLeaderboardSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverMainAxisGroup(
      slivers: [ImmortalForgesSection(), LeaderBoardListSection()],
    );
  }
}

class ImmortalForgesSection extends StatelessWidget {
  const ImmortalForgesSection({super.key});
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImmortalForgesCubit, ImmortalForgesState>(
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        toastification.showErrorToast(error, context);
      },
      builder: (context, state) {
        final cubit = context.read<ImmortalForgesCubit>();
        final selectedFaction = state.selectedFaction;
        final isLoading = state.isLoading;

        final isEmpty = state.currentList.isEmpty;

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.leaf(
                    child: MultiOptionSwitcher<Faction>(
                      selectedValue: selectedFaction,
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
              // 2. Top 3 Card (Immortal Forces)
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.replace(
                    replacement: const ImmortalForcesCardShimmer(),
                    child: isEmpty
                        ? ImmortalForcesCardEmpty(faction: selectedFaction)
                        : ImmortalForcesCard(
                            users: state.currentList,
                          ),
                  ).animateEntrance(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LeaderBoardListSection extends StatelessWidget {
  const LeaderBoardListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mockUsers = generateMockUsers();
    return BlocConsumer<UsersLeaderboardCubit, UsersLeaderboardState>(
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        toastification.showErrorToast(error, context);
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
        final currentUsers = isLoading ? mockUsers : state.currentUsersList;
        final isPaginationLoading = state.isPaginationLoading;

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
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
