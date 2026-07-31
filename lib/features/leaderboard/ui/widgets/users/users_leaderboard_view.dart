import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/immortal_forges_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class UsersLeaderboardView extends StatelessWidget {
  const UsersLeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverMainAxisGroup(
      slivers: [
        ImmortalForgesSection(),
        SliverPadding(padding: EdgeInsets.only(bottom: 90), sliver: LeaderBoardListSection()),
      ],
    );
  }
}

class ImmortalForgesSection extends StatelessWidget {
  const ImmortalForgesSection({super.key});

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  @override
  Widget build(BuildContext context) {
    final guide = context.read<LeaderboardGuide?>();

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
        final factionSelector = MultiOptionSwitcher<Faction>(
          selectedValue: selectedFaction,
          values: Faction.values,
          labelBuilder: (value) => value.title(t),
          onSelected: cubit.changeFaction,
          borderRadius: BorderRadius.circular(50),
          padding: const EdgeInsets.all(3),
          itemTextStyle: subheadH5Medium.copyWith(color: context.appTheme.beige100),
        );
        final factionSelectorTarget = guide == null
            ? factionSelector
            : GuideTarget(
                anchor: guide.anchor(LeaderboardGuideStep.factionSelector),
                scope: leaderboardPageGuideScope,
                tooltip: guide.tooltip(
                  LeaderboardGuideStep.factionSelector,
                  immortalForgesCubit: cubit,
                ),
                child: factionSelector,
              );
        final immortalForgesCard = isEmpty
            ? ImmortalForcesCardEmpty(faction: selectedFaction)
            : ImmortalForcesCard(users: state.currentList);
        final immortalForgesTarget = guide == null
            ? immortalForgesCard
            : GuideTarget(
                anchor: guide.anchor(LeaderboardGuideStep.immortalForges),
                scope: leaderboardPageGuideScope,
                tooltip: guide.tooltip(
                  LeaderboardGuideStep.immortalForges,
                  immortalForgesCubit: cubit,
                ),
                child: immortalForgesCard,
              );

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.leaf(
                    child: factionSelectorTarget,
                  ),
                ),
              ),
              // 2. Top 3 Card (Immortal Forces)
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.replace(
                    replacement: const ImmortalForcesCardShimmer(),
                    child: immortalForgesTarget.animateEntrance(),
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

class LeaderBoardListSection extends StatelessWidget {
  const LeaderBoardListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mockUsers = generateMockUsers();
    return BlocConsumer<UsersLeaderboardCubit, UsersLeaderboardState>(
      listenWhen: (prev, curr) =>
          prev.error != curr.error && curr.error != null ||
          prev.paginationError != curr.paginationError && curr.paginationError != null,
      listener: (context, state) {
        final error = state.error;
        if (error != null) {
          toastification.showErrorToast(error, context);
          return;
        }
        final paginationError = state.paginationError;
        if (paginationError != null) {
          toastification.showErrorToast(paginationError, context);
        }
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
                      t.leaderboard.usersList.title,
                      style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: LeaderBoardUsersList(users: currentUsers),
              ),

              if (isPaginationLoading)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  sliver: SliverToBoxAdapter(child: PaginationLoader()),
                ),

              if (state.paginationError != null && !state.isPaginationLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: TextButton(
                        onPressed: () => context.read<UsersLeaderboardCubit>().loadNextPage(),
                        child: Text(t.leaderboard.usersList.retry),
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
