import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/controller/leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_top_card.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';

class UsersLeaderboardSlivers extends StatelessWidget {
  const UsersLeaderboardSlivers({
    required this.state,
    super.key,
  });

  final LeaderboardState state;

  @override
  Widget build(BuildContext context) {
    final currentUsers = state.currentUsersList;
    final isLoading = state.status == LeaderboardStatus.loading;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: MultiOptionSwitcher<Faction>(
                selectedValue: state.selectedFaction,
                values: Faction.values,
                labelBuilder: (value) => value.title(t),
                onSelected: (value) async {
                  await context.read<LeaderboardCubit>().loadUsers(value);
                },
              ),
            ),
          ),
        ),

        if (currentUsers.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ImmortalForcesCard(
                  users: currentUsers,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
              ),
            ),
          ),

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

        if (isLoading && currentUsers.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: LeaderBoardUsersList(
              users: currentUsers,
              currentUserIndex: state.currentUserIndex,
            ),
          ),
      ],
    );
  }
}
