import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/ui/widgets/activity_section.dart';
import 'package:reforge/features/home/ui/widgets/home_app_bar.dart';
import 'package:reforge/features/home/ui/widgets/portal_dropdown.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/selector_suffix_icon.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: const HomeAppBar(),
      body: DefaultBackground(
        body: const HomeBody(),

        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.home(color: appTheme.orange500),
          ),
        ],
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              Padding(
                padding: const .only(bottom: 16),
                child: AvatarCard(
                  rank: RankEntity.mock(),
                ),
              ),

              Padding(
                padding: const .only(bottom: 16),
                child: AppListTile(
                  leadingIcon: AppIconButton(
                    iconAsset: Assets.images.icons.dumbbell,
                  ),
                  title: 'Forge Today’s Workout',
                  subtitle: 'Start workout',
                  onTap: () async {
                    await const WorkoutDetailsPageRoute().push<void>(context);
                  },
                ),
              ),

              Padding(
                padding: const .only(bottom: 16),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    const Text(
                      'Workout results',
                      style: subheadH2Medium,
                    ),

                    PortalDropdown(
                      targetAnchor: .centerRight,
                      // portalAnchor: .,
                      contentPadding: const EdgeInsets.only(top: 24, left: 18, right: 18),
                      triggerBuilder: (context, isOpened) {
                        final appTheme = context.appTheme;
                        return BlurContainer(
                          child: BaseGlassContainer(
                            glassEffectGradientAlignmentBegin: Alignment.topLeft,
                            glassEffectGradientAlignmentEnd: Alignment.bottomRight,
                            borderGradientStops: const [0.0, 0.1, 0.3, 0.9, 1.0],
                            borderGradientColors: [
                              Colors.transparent,
                              appTheme.beige100,
                              Colors.transparent,

                              Colors.transparent,
                              appTheme.beige100,
                            ],
                            borderColor: appTheme.beige100.withValues(alpha: 0.1),

                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  const Text('Last week'),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  SelectorSuffixIcon(
                                    isOpen: isOpened,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      contentBuilder: (context, onClose) {
                        return Container(
                          height: 200,
                          //width: 100,
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const .only(bottom: 16),
                child: BadgeListTile(
                  leadingIcon: AppIconButton(iconAsset: Assets.images.icons.bell),
                  title: 'Foundryman',
                  subtitle: 'Badge earned',
                  xp: 2738,
                ),
              ),
              const Padding(
                padding: .only(bottom: 16),
                child: XpTile(
                  currentXp: 3190,
                  totalXp: 8215,
                ),
              ),
              const ActivitySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgeListTile extends StatelessWidget {
  const BadgeListTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.xp,
    super.key,
  });

  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: .start,
            spacing: 7,
            children: [
              Text(
                title,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),

              Text(
                subtitle,
                style: subheadH6Regular.copyWith(color: appTheme.beige600),
              ),
            ],
          ),
          const Spacer(),
          Text('${xp}xp'),
        ],
      ),
    );
  }
}
