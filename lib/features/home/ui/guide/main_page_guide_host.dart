import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/ui/guide/home_page_guide_scope.dart';
import 'package:reforge/features/home/ui/guide/main_page_guide_eligibility.dart';

class MainPageGuideHost extends StatefulWidget {
  const MainPageGuideHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<MainPageGuideHost> createState() => _MainPageGuideHostState();
}

class _MainPageGuideHostState extends State<MainPageGuideHost> {
  static const _maxStartAttempts = 5;

  final MainPageGuide _guide = MainPageGuide();
  late final ShowcaseGuideDriver _guideDriver;
  late final GuideCubit _guideCubit;
  int _startRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _guideDriver = ShowcaseGuideDriver(scope: homePageGuideScope);
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

    final homeState = context.read<HomeCubit>().state;
    if (!canStartMainPageGuide(homeState)) return;

    final result = await _guideCubit.startIfNeeded(
      userId: homeState.user!.id,
      session: _guide.session,
    );
    if (!mounted || requestToken != _startRequestToken) return;
    if (result != GuideStartResult.notReady) return;

    if (attempt < _maxStartAttempts) {
      _scheduleAttempt(
        requestToken: requestToken,
        attempt: attempt + 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<MainPageGuide>.value(
      value: _guide,
      child: BlocProvider.value(
        value: _guideCubit,
        child: BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) {
            return previous.isLoading != current.isLoading ||
                previous.user?.id != current.user?.id ||
                previous.currentStats != current.currentStats ||
                previous.rank != current.rank;
          },
          listener: (_, _) => _requestStart(),
          child: widget.child,
        ),
      ),
    );
  }
}
