import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/plate_of_keragura_guide.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/ui/guide/lore_page_guide_scope.dart';
import 'package:reforge/features/lore/ui/guide/plate_of_keragura_guide_eligibility.dart';

typedef PlateOfKeraguraGuideBuilder =
    Widget Function(
      BuildContext context,
      PlateOfKeraguraGuide guide,
      GuideState guideState,
    );

class PlateOfKeraguraGuideHost extends StatefulWidget {
  const PlateOfKeraguraGuideHost({
    required this.builder,
    super.key,
  });

  final PlateOfKeraguraGuideBuilder builder;

  @override
  State<PlateOfKeraguraGuideHost> createState() => _PlateOfKeraguraGuideHostState();
}

class _PlateOfKeraguraGuideHostState extends State<PlateOfKeraguraGuideHost> {
  static const _maxStartAttempts = 5;

  final PlateOfKeraguraGuide _guide = PlateOfKeraguraGuide();
  late final ShowcaseGuideDriver _guideDriver;
  late final GuideCubit _guideCubit;
  int _startRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _guideDriver = ShowcaseGuideDriver(scope: lorePageGuideScope);
    _guideCubit = GuideCubit(
      di.getIt<GuideProgressRepository>(),
      _guideDriver,
    );
    _requestStart();
  }

  @override
  void dispose() {
    _startRequestToken++;
    unawaited(_guideCubit.close());
    super.dispose();
  }

  void _requestStart() {
    final requestToken = ++_startRequestToken;
    final userId = context.read<UserCubit>().state.userOrNull?.id;
    if (userId == null ||
        !_guideCubit.shouldAttemptStart(
          userId: userId,
          guideId: GuideId.plateOfKeragura,
        )) {
      return;
    }

    _scheduleAttempt(requestToken: requestToken, attempt: 1);
  }

  void _scheduleAttempt({
    required int requestToken,
    required int attempt,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _attemptStart(
          requestToken: requestToken,
          attempt: attempt,
        ),
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _attemptStart({
    required int requestToken,
    required int attempt,
  }) async {
    if (!mounted || requestToken != _startRequestToken) return;

    final user = context.read<UserCubit>().state.userOrNull;
    if (user == null ||
        !_guideCubit.shouldAttemptStart(
          userId: user.id,
          guideId: GuideId.plateOfKeragura,
        )) {
      return;
    }

    final loreState = context.read<LoreCubit>().state;
    if (!canStartPlateOfKeraguraGuide(
      state: loreState,
      userId: user.id,
    )) {
      return;
    }

    final hasUnlockedPlate = loreState.items.any(
      (plate) => !plate.isLocked,
    );
    final hasLockedPlate = loreState.items.any((plate) => plate.isLocked);
    if (!hasUnlockedPlate && !hasLockedPlate) return;

    final fullSession = _guide.session(
      includeUnlockedPlate: hasUnlockedPlate,
      includeLockedPlate: hasLockedPlate,
    );
    final result = await _guideCubit.startIfNeeded(
      userId: user.id,
      session: fullSession,
    );
    if (!mounted || requestToken != _startRequestToken) return;
    if (result != GuideStartResult.notReady) return;

    if (attempt < _maxStartAttempts) {
      _scheduleAttempt(
        requestToken: requestToken,
        attempt: attempt + 1,
      );
      return;
    }

    if (hasUnlockedPlate && hasLockedPlate) {
      await _startReducedSession(
        requestToken: requestToken,
        userId: user.id,
      );
    }
  }

  Future<void> _startReducedSession({
    required int requestToken,
    required int userId,
  }) async {
    final unlockedResult = await _guideCubit.startIfNeeded(
      userId: userId,
      session: _guide.session(
        includeUnlockedPlate: true,
        includeLockedPlate: false,
      ),
    );
    if (!mounted || requestToken != _startRequestToken || unlockedResult != GuideStartResult.notReady) {
      return;
    }

    await _guideCubit.startIfNeeded(
      userId: userId,
      session: _guide.session(
        includeUnlockedPlate: false,
        includeLockedPlate: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _guideCubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoreCubit, LoreState>(
            listenWhen: (previous, current) => previous.isLoading != current.isLoading,
            listener: (_, _) => _requestStart(),
          ),
          BlocListener<UserCubit, UserState>(
            listener: (_, _) => _requestStart(),
          ),
        ],
        child: BlocBuilder<GuideCubit, GuideState>(
          builder: (context, state) {
            return widget.builder(context, _guide, state);
          },
        ),
      ),
    );
  }
}
