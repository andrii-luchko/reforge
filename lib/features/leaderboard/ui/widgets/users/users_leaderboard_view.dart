import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forge_rank.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/immortal_forges_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/immortal_forges_guide.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class UsersLeaderboardView extends StatelessWidget {
  const UsersLeaderboardView({
    required this.guideKeys,
    required this.onStartGuide,
    super.key,
  });

  final ImmortalForgesGuideKeys guideKeys;
  final ValueChanged<List<GlobalKey>> onStartGuide;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ImmortalForgesSection(guideKeys: guideKeys, onStartGuide: onStartGuide),
        const SliverPadding(padding: EdgeInsets.only(bottom: 90), sliver: LeaderBoardListSection()),
      ],
    );
  }
}

class ImmortalForgesSection extends StatelessWidget {
  const ImmortalForgesSection({
    required this.guideKeys,
    required this.onStartGuide,
    super.key,
  });

  final ImmortalForgesGuideKeys guideKeys;
  final ValueChanged<List<GlobalKey>> onStartGuide;
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
        final guideAvailable = state.areAllFactionsLoaded && !isEmpty;
        final guideSteps = guideKeys.stepsFor(state.currentList);
        final guide = t.leaderboard.immortalForges.guide;
        final guideTooltips = <ImmortalForgeRank, Widget>{
          for (final rank in ImmortalForgeRank.values)
            if (state.currentList.any((user) => user.rank == rank.rank))
              rank: _rankTooltip(
                rank: rank,
                faction: selectedFaction,
                currentStep: guideSteps.indexOf(guideKeys.rank(rank)) + 1,
                totalSteps: guideSteps.length,
              ),
        };

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.leaf(
                    child: Showcase.withWidget(
                      key: guideKeys.factionSelector,
                      scope: ImmortalForgesGuideKeys.scope,
                      targetPadding: const EdgeInsets.all(6),
                      container: ImmortalForgesGuideTooltip(
                        title: guide.factionTitle,
                        description: guide.factionDescription,
                        currentStep: 1,
                        totalSteps: guideSteps.length,
                      ),
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
              ),
              // 2. Top 3 Card (Immortal Forces)
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.replace(
                    replacement: const ImmortalForcesCardShimmer(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Showcase.withWidget(
                          key: guideKeys.overview,
                          scope: ImmortalForgesGuideKeys.scope,
                          targetPadding: const EdgeInsets.all(6),
                          container: ImmortalForgesGuideTooltip(
                            title: guide.overviewTitle,
                            description: '${guide.overviewDescription}\n\n${guide.forgesDescription}',
                            currentStep: 2,
                            totalSteps: guideSteps.length,
                          ),
                          child: isEmpty
                              ? ImmortalForcesCardEmpty(faction: selectedFaction)
                              : ImmortalForcesCard(
                                  users: state.currentList,
                                  guideKeys: guideKeys,
                                  guideTooltips: guideTooltips,
                                ),
                        ),
                        if (guideAvailable)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Semantics(
                              button: true,
                              label: guide.helpLabel,
                              child: AppIconButton.icon(
                                iconData: Icons.question_mark_rounded,
                                width: 36,
                                height: 36,
                                iconSize: 18,
                                onPressed: () => onStartGuide(guideSteps),
                              ),
                            ),
                          ),
                      ],
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

  Widget _rankTooltip({
    required ImmortalForgeRank rank,
    required Faction faction,
    required int currentStep,
    required int totalSteps,
  }) {
    final content = forgeGuideContent(rank, faction);
    return ImmortalForgesGuideTooltip(
      title: content.title,
      subtitle: content.subtitle,
      description: content.description,
      currentStep: currentStep,
      totalSteps: totalSteps,
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
