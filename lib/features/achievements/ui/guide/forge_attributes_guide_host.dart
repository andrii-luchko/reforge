import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/achievements/ui/guide/forge_attributes_guide_eligibility.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';

class ForgeAttributesGuideHost extends StatefulWidget {
  const ForgeAttributesGuideHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ForgeAttributesGuideHost> createState() => _ForgeAttributesGuideHostState();
}

class _ForgeAttributesGuideHostState extends State<ForgeAttributesGuideHost> {
  static const _maxStartAttempts = 5;

  final ForgeAttributesGuide _guide = ForgeAttributesGuide();
  late final ShowcaseGuideDriver _guideDriver;
  late final GuideCubit _guideCubit;
  int _startRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _guideDriver = ShowcaseGuideDriver(scope: achievementsPageGuideScope);
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
          guideId: GuideId.forgeAttributes,
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
          guideId: GuideId.forgeAttributes,
        )) {
      return;
    }

    final achievementsState = context.read<AchievementsCubit>().state;
    if (!canStartForgeAttributesGuide(
      state: achievementsState,
      userId: user.id,
    )) {
      return;
    }

    final session = _guide.session(
      availableAttributes: achievementsState.attributes.map(
        (entity) => entity.attribute,
      ),
      includeBadges: achievementsState.badges.isNotEmpty,
    );
    if (session == null) return;

    final result = await _guideCubit.startIfNeeded(
      userId: user.id,
      session: session,
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

  Set<ForgeAttribute> _attributeTypes(AchievementsState state) {
    return state.attributes.map((entity) => entity.attribute).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ForgeAttributesGuide>.value(
      value: _guide,
      child: BlocProvider.value(
        value: _guideCubit,
        child: MultiBlocListener(
          listeners: [
            BlocListener<AchievementsCubit, AchievementsState>(
              listenWhen: (previous, current) {
                return previous.isLoading != current.isLoading ||
                    !setEquals(
                      _attributeTypes(previous),
                      _attributeTypes(current),
                    );
              },
              listener: (_, _) => _requestStart(),
            ),
            BlocListener<UserCubit, UserState>(
              listener: (_, _) => _requestStart(),
            ),
          ],
          child: widget.child,
        ),
      ),
    );
  }
}
