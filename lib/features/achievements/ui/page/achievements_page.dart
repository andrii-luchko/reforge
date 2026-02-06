import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/attribute_system_section.dart';
import 'package:reforge/features/achievements/ui/widgets/common_heder_delegate.dart';
import 'package:reforge/features/achievements/ui/widgets/sliver_badges_grid.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16),
                sliver: SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: false,
                  actionsPadding: const .only(right: 8),
                  title: Skeleton.keep(
                    child: Text(
                      'Rank',
                      style: subheadH1Medium.copyWith(color: appTheme.beige100),
                    ),
                  ),
                  actions: [
                    ThirtyButton(
                      text: 'Learn more',
                      onPressed: () => GoRouter.of(context).push(
                        const RanksPageRoute().location,
                      ),
                    ),
                  ],
                ),
              ),

              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 16),
                sliver: const SliverToBoxAdapter(
                  child: AvatarCard(
                    faction: 'YAMAKATA',
                    lvl: 78,
                    rankName: 'Foundryman',
                    xpValue: 0.7,
                  ),
                ),
              ),
              SliverPadding(
                padding: horizontalPadding.copyWith(bottom: 16),
                sliver: const SliverToBoxAdapter(
                  child: AttributeSystemSection(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: CommonHeaderDelegate(
                    height: 40,
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Skeleton.keep(
                            child: Text(
                              'Badges',
                              style: subheadH1Medium.copyWith(color: appTheme.beige100),
                            ),
                          ),
                          ThirtyButton(
                            text: 'Learn more',
                            onPressed: () => GoRouter.of(context).push(
                              const BadgesPageRoute().location,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverBadgesGrid(
                  badges: List.generate(
                    3,
                    (i) => BadgeEntity(
                      imageUrl: Assets.images.png.badge.path,
                      title: 'Peak of Might',
                      isLocked: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        additionalAnimationsBehind: const [ParticlesWidget()],
      ),
    );
  }
}
