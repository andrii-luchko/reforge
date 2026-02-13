import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/factions_leaderboard_view.dart';
import 'package:reforge/features/leaderboard/ui/widgets/sparks.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/users_leaderboard_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';

import 'package:reforge/shared/uikit/default_background.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ValueNotifier<LeaderboardMode> _leaderboardModeNotifier = ValueNotifier(.users);

  bool _onScrollNotification(ScrollUpdateNotification notification, BuildContext context) {
    final metrics = notification.metrics;

    const threshold = 200.0;

    if (_leaderboardModeNotifier.value == LeaderboardMode.users &&
        metrics.pixels >= metrics.maxScrollExtent - threshold) {
      final cubit = context.read<UsersLeaderboardCubit>();

      if (!cubit.state.isLoading && !cubit.state.hasReachedMax) {
        unawaited(cubit.loadNextPage());
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,

          child: Stack(
            children: [
              NotificationListener<ScrollUpdateNotification>(
                onNotification: (n) => _onScrollNotification(n, context),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      automaticallyImplyLeading: false,
                      centerTitle: false,

                      floating: true,

                      title: Text(
                        'LeaderBoard',
                        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                      ),

                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(72),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                          child: ValueListenableBuilder(
                            valueListenable: _leaderboardModeNotifier,
                            builder: (context, value, child) {
                              return MultiOptionSwitcher<LeaderboardMode>(
                                selectedValue: value,
                                values: LeaderboardMode.values,
                                labelBuilder: (value) => value.title(t),
                                onSelected: (value) {
                                  _leaderboardModeNotifier.value = value;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    ValueListenableBuilder(
                      valueListenable: _leaderboardModeNotifier,
                      builder: (context, mode, child) {
                        return mode == LeaderboardMode.users
                            ? const UsersLeaderboardView()
                            : const FactionsLeaderboardView();
                      },
                    ),

                    SliverPadding(
                      padding: EdgeInsets.only(bottom: context.appTheme.sliverBottomSpacing),
                    ),
                  ],
                ),
              ),

              ValueListenableBuilder(
                valueListenable: _leaderboardModeNotifier,
                builder: (context, mode, child) {
                  final visible = mode == LeaderboardMode.users;
                  return BlocBuilder<UsersLeaderboardCubit, UsersLeaderboardState>(
                    builder: (context, state) {
                      if (state.currentUser == null) return const SizedBox.shrink();

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: 16,
                        right: 16,
                        bottom: visible ? 100 : -150,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: RisingAuraEffect(
                            child: LeaderboardUserListTile(user: state.currentUser!),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        additionalAnimationsBehind: const [ParticlesWidget()],
      ),
    );
  }
}
