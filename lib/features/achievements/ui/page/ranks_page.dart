import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';

import 'package:reforge/features/achievements/domain/mock/generate_ranks.dart';
import 'package:reforge/features/achievements/ui/widgets/deep_stack_scroll.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RanksPage extends StatelessWidget {
  const RanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AchievementsCubit>();
    final appTheme = context.appTheme;

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocBuilder<AchievementsCubit, AchievementsState>(
            builder: (context, state) {
              final displayRanks = (state.selectedRanks.isEmpty && state.isLoading)
                  ? RanksGenerator.generateRanks(state.selectedFaction)
                  : state.selectedRanks;

              return Skeletonizer(
                enabled: state.isLoading,
                child: RefreshIndicator(
                  onRefresh: () async {
                    cubit.onRanksRefresh();
                    await cubit.loadRanks(forceRefresh: true);
                  },
                  child: CustomScrollView(
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
                                t.achievements.ranks,
                                style: subheadH1Medium.copyWith(color: appTheme.beige100),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      SliverPadding(
                        padding: horizontalPadding.copyWith(bottom: 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: .start,
                            spacing: 16,
                            children: [
                              Text(t.achievements.rankFaction, style: subheadH2Medium.copyWith(color: appTheme.beige100)),

                              Skeleton.leaf(
                                child: MultiOptionSwitcher<Faction>(
                                  selectedValue: state.selectedFaction,
                                  values: Faction.values,
                                  labelBuilder: (d) => d.title(t),
                                  onSelected: cubit.changeFaction,
                                  borderRadius: BorderRadius.circular(50),
                                  padding: const EdgeInsets.all(3),
                                  itemTextStyle: subheadH5Medium.copyWith(color: context.appTheme.beige100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: horizontalPadding.copyWith(top: 32, bottom: 32),
                        sliver: SliverFillRemaining(
                          hasScrollBody: false,
                          child: displayRanks.isEmpty && !state.isLoading
                              ? Center(child: Text(t.achievements.noRanksFound))
                              : DeepStackScroll(
                                  children: displayRanks
                                      .map(
                                        (rank) => Skeleton.replace(
                                          width: 358,
                                          height: 484,
                                          replacement: const AvatarCardShimmer(),
                                          child: AvatarRankCard(rank: rank),
                                        ).animateEntrance(),
                                      )
                                      .toList(),
                                ),
                        ),
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
