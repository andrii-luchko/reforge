import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/faction_wars_guide_eligibility.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_guide_eligibility.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';

class LeaderboardGuidesHost extends StatefulWidget {
  const LeaderboardGuidesHost({
    required this.modeListenable,
    required this.child,
    super.key,
  });

  final ValueListenable<LeaderboardMode> modeListenable;
  final Widget child;

  @override
  State<LeaderboardGuidesHost> createState() => _LeaderboardGuidesHostState();
}

class _LeaderboardGuidesHostState extends State<LeaderboardGuidesHost> {
  static const _maxStartAttempts = 5;

  final LeaderboardGuide _leaderboardGuide = LeaderboardGuide();
  final FactionWarsGuide _factionWarsGuide = FactionWarsGuide();
  late final GuideCubit _guideCubit;
  int _startRequestToken = 0;
  bool _initialStartRequested = false;

  @override
  void initState() {
    super.initState();
    _guideCubit = GuideCubit(
      di.getIt<GuideProgressRepository>(),
      ShowcaseGuideDriver(scope: leaderboardPageGuideScope),
    );
    widget.modeListenable.addListener(_requestStart);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialStartRequested) return;

    _initialStartRequested = true;
    _requestStart();
  }

  @override
  void didUpdateWidget(covariant LeaderboardGuidesHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modeListenable == widget.modeListenable) return;

    oldWidget.modeListenable.removeListener(_requestStart);
    widget.modeListenable.addListener(_requestStart);
    _requestStart();
  }

  @override
  void dispose() {
    widget.modeListenable.removeListener(_requestStart);
    _startRequestToken++;
    unawaited(_guideCubit.close());
    super.dispose();
  }

  void _requestStart() {
    final requestToken = ++_startRequestToken;
    final userId = context.read<UserCubit>().state.userOrNull?.id;
    if (userId == null) return;

    final mode = widget.modeListenable.value;
    final guideId = _guideId(mode);
    if (!_guideCubit.shouldAttemptStart(
      userId: userId,
      guideId: guideId,
    )) {
      return;
    }

    _scheduleAttempt(
      requestToken: requestToken,
      attempt: 1,
      userId: userId,
      mode: mode,
    );
  }

  void _scheduleAttempt({
    required int requestToken,
    required int attempt,
    required int userId,
    required LeaderboardMode mode,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _attemptStart(
          requestToken: requestToken,
          attempt: attempt,
          userId: userId,
          mode: mode,
        ),
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _attemptStart({
    required int requestToken,
    required int attempt,
    required int userId,
    required LeaderboardMode mode,
  }) async {
    if (!mounted ||
        requestToken != _startRequestToken ||
        widget.modeListenable.value != mode ||
        context.read<UserCubit>().state.userOrNull?.id != userId) {
      return;
    }

    final session = _session(mode);
    if (!_guideCubit.shouldAttemptStart(
      userId: userId,
      guideId: session.id,
    )) {
      return;
    }

    final isEligible = switch (mode) {
      LeaderboardMode.users => canStartLeaderboardGuide(
        mode: mode,
        state: context.read<ImmortalForgesCubit>().state,
        userId: userId,
      ),
      LeaderboardMode.factions => canStartFactionWarsGuide(
        mode: mode,
        state: context.read<FactionsLeaderboardCubit>().state,
        userId: userId,
      ),
    };
    if (!isEligible) return;

    final result = await _guideCubit.startIfNeeded(
      userId: userId,
      session: session,
    );
    if (!mounted || requestToken != _startRequestToken || result != GuideStartResult.notReady) {
      return;
    }

    if (attempt < _maxStartAttempts) {
      _scheduleAttempt(
        requestToken: requestToken,
        attempt: attempt + 1,
        userId: userId,
        mode: mode,
      );
    }
  }

  GuideId _guideId(LeaderboardMode mode) {
    return switch (mode) {
      LeaderboardMode.users => GuideId.leaderboard,
      LeaderboardMode.factions => GuideId.factionWars,
    };
  }

  GuideSession _session(LeaderboardMode mode) {
    return switch (mode) {
      LeaderboardMode.users => _leaderboardGuide.session,
      LeaderboardMode.factions => _factionWarsGuide.session,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Provider<LeaderboardGuide>.value(
      value: _leaderboardGuide,
      child: Provider<FactionWarsGuide>.value(
        value: _factionWarsGuide,
        child: BlocProvider.value(
          value: _guideCubit,
          child: MultiBlocListener(
            listeners: [
              BlocListener<ImmortalForgesCubit, ImmortalForgesState>(
                listener: (_, _) => _requestStart(),
              ),
              BlocListener<UserCubit, UserState>(
                listener: (_, _) => _requestStart(),
              ),
              BlocListener<FactionsLeaderboardCubit, FactionsLeaderboardState>(
                listener: (_, _) => _requestStart(),
              ),
            ],
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
