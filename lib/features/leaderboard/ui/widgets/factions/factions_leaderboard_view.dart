import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_factions.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/faction_leaderboard_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/faction_mode_picker.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/leaderboard_faction_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/victory_point_section.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class FactionsLeaderboardView extends StatelessWidget {
  const FactionsLeaderboardView({required this.guide, super.key});

  final FactionWarsGuide guide;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FactionsLeaderboardCubit>();

    return BlocConsumer<FactionsLeaderboardCubit, FactionsLeaderboardState>(
      listenWhen: (previous, current) => current.error != previous.error,
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        toastification.showErrorToast(error, context);
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
        final versusList = state.versusMatchup;
        final userFaction = state.userFaction;

        final showVersusCard = versusList != null && userFaction != null && !isLoading;

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: GuideTarget(
                  anchor: guide.anchor(FactionWarsGuideStep.battleMode),
                  scope: leaderboardPageGuideScope,
                  tooltip: guide.tooltip(FactionWarsGuideStep.battleMode),
                  child: FactionLeaderboardModePiker(
                    selectedMode: state.selectedMode,
                    onModeChanged: cubit.changeMode,
                  ),
                ).animateEntrance(),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Skeleton.replace(
                    key: ValueKey(state.selectedMode),
                    replacement: const FactionLeaderboardCardShimmer(),

                    child: showVersusCard
                        ? GuideTarget(
                            anchor: guide.anchor(FactionWarsGuideStep.monthlyRewards),
                            scope: leaderboardPageGuideScope,
                            tooltip: guide.tooltip(FactionWarsGuideStep.monthlyRewards),
                            child: FactionLeaderboardCard(
                              mode: state.selectedMode,
                              firstFaction: versusList.myFaction,
                              secondFaction: versusList.opponent,
                              userFaction: userFaction,
                              currentWeek: 2,
                              totalWeeks: 4,
                              guide: guide,
                            ),
                          )
                        : const FactionLeaderboardCardError(),
                  ).animateEntrance(),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.list(
                  children: [
                    Text(
                      t.leaderboard.factions.warStandings,
                      style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                    ),
                    const SizedBox(height: 16),

                    Skeleton.leaf(
                      child: MultiOptionSwitcher<FactionShowType>(
                        selectedValue: state.selectedType,
                        values: FactionShowType.values,
                        labelBuilder: (value) => value.title(t),
                        onSelected: cubit.changeShowType,
                        borderRadius: BorderRadius.circular(50),
                        padding: const EdgeInsets.all(3),
                        itemTextStyle: subheadH5Medium.copyWith(color: context.appTheme.beige100),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              _LeaderboardContent(state: state, guide: guide),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({required this.state, required this.guide});

  final FactionsLeaderboardState state;
  final FactionWarsGuide guide;

  @override
  Widget build(BuildContext context) {
    final mockFaction = generateMockFactions();
    final isLoading = state.isLoading;
    final currentFaction = isLoading ? mockFaction : state.factionsSortByMode;

    switch (state.selectedType) {
      case FactionShowType.list:
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: LeaderboardFactionList(
            factions: currentFaction,
            mode: state.selectedMode,
            guide: guide,
          ),
        );

      case FactionShowType.victoryPoints:
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: currentFaction.isEmpty
              ? SliverEmptyListMessage(
                  title: t.leaderboard.factions.emptyTitle,
                  subtitle: t.leaderboard.factions.emptySubtitle,
                  icon: Icons.groups_3_outlined,
                )
              : SliverToBoxAdapter(
                  child: VictoryPointSection(
                    factions: currentFaction,
                    mode: state.selectedMode,
                  ).animateEntrance(),
                ),
        );
    }
  }
}
