import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/faction_wars_guide_eligibility.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_guide_eligibility.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/factions_leaderboard_view.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/users_leaderboard_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/animations/rising_aura_effect.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
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
  final LeaderboardGuide _leaderboardGuide = LeaderboardGuide();
  final FactionWarsGuide _factionWarsGuide = FactionWarsGuide();
  late final GuideCubit _guideCubit;
  bool _hasOpenedFactions = false;

  @override
  void initState() {
    super.initState();
    _guideCubit = GuideCubit(
      di.getIt<GuideProgressRepository>(),
      ShowcaseGuideDriver(scope: leaderboardPageGuideScope),
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartGuide());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _leaderboardModeNotifier.dispose();
    unawaited(_guideCubit.close());
    super.dispose();
  }

  void _scheduleGuideStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartGuide());
  }

  void _maybeStartGuide() {
    if (!mounted) return;

    final user = context.read<UserCubit>().state.userOrNull;
    final mode = _leaderboardModeNotifier.value;

    switch (mode) {
      case LeaderboardMode.users:
        final state = context.read<ImmortalForgesCubit>().state;
        if (!canStartLeaderboardGuide(mode: mode, state: state, userId: user?.id)) return;
        unawaited(_guideCubit.startIfNeeded(userId: user!.id, session: _leaderboardGuide.session));
      case LeaderboardMode.factions:
        final state = context.read<FactionsLeaderboardCubit>().state;
        if (!canStartFactionWarsGuide(mode: mode, state: state, userId: user?.id)) return;
        unawaited(_guideCubit.startIfNeeded(userId: user!.id, session: _factionWarsGuide.session));
    }
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
    return BlocProvider.value(
      value: _guideCubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ImmortalForgesCubit, ImmortalForgesState>(
            listener: (_, _) => _scheduleGuideStart(),
          ),
          BlocListener<UserCubit, UserState>(
            listener: (_, _) => _scheduleGuideStart(),
          ),
          BlocListener<FactionsLeaderboardCubit, FactionsLeaderboardState>(
            listener: (_, _) => _scheduleGuideStart(),
          ),
        ],
        child: Scaffold(
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
                    child: BlocBuilder<GuideCubit, GuideState>(
                      builder: (context, state) {
                        final guideIsRunning = state is GuideRunning;
                        return CustomScrollView(
                          controller: _scrollController,
                          scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
                          physics: guideIsRunning
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          slivers: [
                            SliverAppBar(
                              backgroundColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              automaticallyImplyLeading: false,
                              centerTitle: false,
                              title: Text(
                                t.leaderboard.title,
                                style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                              sliver: SliverToBoxAdapter(
                                child: GuideTarget(
                                  anchor: _leaderboardGuide.anchor(LeaderboardGuideStep.intro),
                                  scope: leaderboardPageGuideScope,
                                  tooltip: _leaderboardGuide.tooltip(LeaderboardGuideStep.intro),
                                  targetPadding: EdgeInsets.zero,
                                  targetBorderRadius: BorderRadius.zero,
                                  child: GuideTarget(
                                    anchor: _factionWarsGuide.anchor(FactionWarsGuideStep.intro),
                                    scope: leaderboardPageGuideScope,
                                    tooltip: _factionWarsGuide.tooltip(FactionWarsGuideStep.intro),
                                    targetPadding: EdgeInsets.zero,
                                    targetBorderRadius: BorderRadius.zero,
                                    child: ValueListenableBuilder(
                                      valueListenable: _leaderboardModeNotifier,
                                      builder: (context, value, child) {
                                        return MultiOptionSwitcher<LeaderboardMode>(
                                          selectedValue: value,
                                          values: LeaderboardMode.values,
                                          labelBuilder: (value) => value.title(t),
                                          onSelected: (value) {
                                            if (_guideCubit.state is GuideChecking ||
                                                _guideCubit.state is GuideRunning) {
                                              return;
                                            }
                                            unawaited(
                                              di.getIt<AnalyticsService>().logEvent(
                                                AnalyticsEvents.leaderboardModeChange,
                                                {'mode': value.name},
                                              ),
                                            );
                                            if (value == LeaderboardMode.factions && !_hasOpenedFactions) {
                                              _hasOpenedFactions = true;
                                              context.read<FactionsLeaderboardCubit>().setShowType(
                                                FactionShowType.list,
                                              );
                                            }
                                            _leaderboardModeNotifier.value = value;
                                            _scheduleGuideStart();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _leaderboardModeNotifier,
                              builder: (context, mode, child) {
                                return mode == LeaderboardMode.users
                                    ? UsersLeaderboardView(guide: _leaderboardGuide)
                                    : FactionsLeaderboardView(guide: _factionWarsGuide);
                              },
                            ),

                            const AppBottomPaddingWidget.sliverWithAppBottomBarHeight(),
                          ],
                        );
                      },
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
        ),
      ),
    );
  }
}
