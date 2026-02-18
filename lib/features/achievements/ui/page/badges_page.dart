import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/achievements/ui/widgets/common_heder_delegate.dart';
import 'package:reforge/features/achievements/ui/widgets/sliver_badges_grid.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  @override
  void initState() {
    super.initState();
    unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.achievementsBadgesView));
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final cubit = context.read<AchievementsCubit>();

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocBuilder<AchievementsCubit, AchievementsState>(
            builder: (context, state) {
              final badges = state.badges;

              return Skeletonizer(
                enabled: state.isLoading,
                child: RefreshIndicator(
                  onRefresh: () async {
                    cubit.onBadgesRefresh();
                    await cubit.loadBadges(forceRefresh: true);
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: horizontalPadding,
                        sliver: SliverAppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          automaticallyImplyLeading: false,

                          centerTitle: false,
                          leadingWidth: 56,
                          leading: AppIconButton.icon(
                            iconData: Icons.chevron_left_rounded,
                            iconSize: 32,
                            onPressed: Navigator.of(context).pop,
                          ),

                          actions: [
                            Skeleton.keep(
                              child: Text(
                                t.achievements.badges,
                                style: subheadH1Medium.copyWith(color: appTheme.beige100),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      SliverPersistentHeader(
                        pinned: true,
                        delegate: CommonHeaderDelegate(
                          height: 30,
                          child: Container(
                            height: 30,
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Skeleton.keep(
                                  child: Text(
                                    t.achievements.badgesList,
                                    style: subheadH1Medium.copyWith(color: appTheme.beige100),
                                  ),
                                ),

                                Text(
                                  t.achievements.itemsCount(unlocked: state.unLockedCount, total: badges.length),
                                  style: subheadH5Medium.copyWith(color: appTheme.beige600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: horizontalPadding.copyWith(top: 16, bottom: 32),
                        sliver: SliverBadgesGrid(badges: badges),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        additionalAnimationsBehind: const [ParticlesWidget()],
      ),
    );
  }
}
