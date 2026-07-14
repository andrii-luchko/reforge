import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forge_rank.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:showcaseview/showcaseview.dart';

class ImmortalForgesGuideKeys {
  static const scope = 'immortal-forges-guide';

  final GlobalKey factionSelector = GlobalKey();
  final GlobalKey overview = GlobalKey();
  final Map<ImmortalForgeRank, GlobalKey> _rankKeys = {
    for (final rank in ImmortalForgeRank.values) rank: GlobalKey(),
  };

  GlobalKey rank(ImmortalForgeRank forge) => _rankKeys[forge]!;

  List<GlobalKey> stepsFor(List<ImmortalForgeEntity> users) {
    final ranks = users.map((user) => ImmortalForgeRank.fromRank(user.rank)).nonNulls.toSet();
    return [
      factionSelector,
      overview,
      for (final rank in ImmortalForgeRank.values)
        if (ranks.contains(rank)) _rankKeys[rank]!,
    ];
  }
}

class ImmortalForgesGuideTooltip extends StatelessWidget {
  const ImmortalForgesGuideTooltip({
    required this.title,
    required this.description,
    required this.currentStep,
    required this.totalSteps,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String description;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final guide = t.leaderboard.immortalForges.guide;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.beige900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.strokeCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$currentStep / $totalSteps', style: bodyLRegular.copyWith(color: theme.beige700)),
              const SizedBox(height: 8),
              Text(title, style: subheadH3Medium.copyWith(color: theme.beige100)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: subheadH6Regular.copyWith(color: theme.orange500)),
              ],
              const SizedBox(height: 8),
              Text(description, style: bodyMRegular.copyWith(color: theme.beige300, height: 1.35)),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: currentStep == 1 ? null : ShowcaseView.getNamed(ImmortalForgesGuideKeys.scope).previous,
                    child: Text(guide.back),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: ShowcaseView.getNamed(ImmortalForgesGuideKeys.scope).dismiss,
                    child: Text(guide.skip),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () => ShowcaseView.getNamed(ImmortalForgesGuideKeys.scope).next(force: true),
                    child: Text(guide.next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({String title, String? subtitle, String description}) forgeGuideContent(
  ImmortalForgeRank rank,
  Faction faction,
) {
  final guide = t.leaderboard.immortalForges.guide;

  return switch (rank) {
    ImmortalForgeRank.daizosho => (
      title: rank.title,
      subtitle: guide.daizoshoSubtitle,
      description: guide.daizoshoDescription,
    ),
    ImmortalForgeRank.might => _mightGuideContent(faction),
    ImmortalForgeRank.judgement => (title: rank.title, subtitle: null, description: guide.judgementDescription),
    ImmortalForgeRank.strife => (title: rank.title, subtitle: null, description: guide.strifeDescription),
    ImmortalForgeRank.burden => (title: rank.title, subtitle: null, description: guide.burdenDescription),
  };
}

({String title, String? subtitle, String description}) _mightGuideContent(Faction faction) {
  final guide = t.leaderboard.immortalForges.guide;

  return switch (faction) {
    Faction.gakki => (
      title: ImmortalForgeRank.might.title,
      subtitle: guide.strengthTitle,
      description: guide.strengthDescription,
    ),
    Faction.gyohyo => (
      title: ImmortalForgeRank.might.title,
      subtitle: guide.runningTitle,
      description: guide.runningDescription,
    ),
    Faction.seiren => (
      title: ImmortalForgeRank.might.title,
      subtitle: guide.flexibilityTitle,
      description: guide.flexibilityDescription,
    ),
  };
}
