import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/factions_leaderboard_view.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/users_leaderboard_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/animations/rising_aura_effect.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ValueNotifier<LeaderboardMode> _leaderboardModeNotifier = ValueNotifier(.users);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_leaderboardModeNotifier.value != LeaderboardMode.users) return;

    final position = _scrollController.position;
    const threshold = 200.0;
    if (position.pixels < position.maxScrollExtent - threshold) return;

    final cubit = context.read<UsersLeaderboardCubit>();
    if (!cubit.state.isLoading && !cubit.state.isPaginationLoading && !cubit.state.hasReachedMax) {
      unawaited(cubit.loadNextPage());
    }
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
              RefreshIndicator(
                onRefresh: () async {
                  final leaderboardCubit = context.read<UsersLeaderboardCubit>();
                  final immortalForgesCubit = context.read<ImmortalForgesCubit>();
                  unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.leaderboardRefresh));
                  if (_leaderboardModeNotifier.value == LeaderboardMode.users) {
                    await Future.wait([
                      leaderboardCubit.loadUsers(),
                      immortalForgesCubit.refresh(),
                    ]);
                  } else {
                    await context.read<FactionsLeaderboardCubit>().loadFactions();
                  }
                },
                child: CustomScrollView(
                  controller: _scrollController,
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
                        t.leaderboard.title,
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
                                  unawaited(
                                    di.getIt<AnalyticsService>().logEvent(
                                      AnalyticsEvents.leaderboardModeChange,
                                      {'mode': value.name},
                                    ),
                                  );
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
                            enabled: state.isWorthy,
                            autoStopDuration: const Duration(minutes: 5),
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
