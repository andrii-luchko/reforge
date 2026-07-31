import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forge_rank.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum LeaderboardGuideStep {
  intro,
  factionSelector,
  immortalForges,
  daizosho,
  might,
  judgement,
  strife,
  burden,
}

class LeaderboardGuide {
  LeaderboardGuide()
    : _anchors = {
        for (final step in LeaderboardGuideStep.values) step: GlobalKey(debugLabel: 'leaderboard-guide-${step.name}'),
      };

  final Map<LeaderboardGuideStep, GlobalKey> _anchors;

  GlobalKey anchor(LeaderboardGuideStep step) => _anchors[step]!;

  GuideSession get session {
    return GuideSession(
      id: GuideId.leaderboard,
      steps: [
        for (final step in LeaderboardGuideStep.values) GuideStep(anchor: anchor(step)),
      ],
    );
  }

  Widget tooltip(
    LeaderboardGuideStep step, {
    ImmortalForgesCubit? immortalForgesCubit,
  }) {
    final guide = t.guides.leaderboard;

    final tooltip = switch (step) {
      LeaderboardGuideStep.intro => GuideTooltip(
        title: guide.introTitle,
        description: guide.introDescription,
      ),
      LeaderboardGuideStep.factionSelector => GuideTooltip(
        title: guide.factionTitle,
        description: guide.factionDescription,
      ),
      LeaderboardGuideStep.immortalForges => GuideTooltip(
        title: guide.forgesTitle,
        description: guide.forgesDescription,
      ),
      LeaderboardGuideStep.might => const _MightGuideTooltip(),
      LeaderboardGuideStep.judgement => GuideTooltip(
        title: ImmortalForgeRank.judgement.title,
        description: guide.judgementDescription,
      ),
      LeaderboardGuideStep.strife => GuideTooltip(
        title: ImmortalForgeRank.strife.title,
        description: guide.strifeDescription,
      ),
      LeaderboardGuideStep.burden => GuideTooltip(
        title: ImmortalForgeRank.burden.title,
        description: guide.burdenDescription,
      ),
      LeaderboardGuideStep.daizosho => GuideTooltip(
        title: ImmortalForgeRank.daizosho.title,
        description: guide.daizoshoDescription,
      ),
    };

    if (immortalForgesCubit == null) return tooltip;
    return BlocProvider.value(value: immortalForgesCubit, child: tooltip);
  }
}

class _MightGuideTooltip extends StatelessWidget {
  const _MightGuideTooltip();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ImmortalForgesCubit, ImmortalForgesState, Faction>(
      selector: (state) => state.selectedFaction,
      builder: (context, faction) {
        final content = _mightGuideContent(faction);
        return GuideTooltip(
          title: ImmortalForgeRank.might.title,
          subtitle: content.title,
          description: content.description,
        );
      },
    );
  }
}

({String title, String description}) _mightGuideContent(Faction faction) {
  final guide = t.guides.leaderboard;

  return switch (faction) {
    Faction.gakki => (title: guide.strengthTitle, description: guide.strengthDescription),
    Faction.gyohyo => (title: guide.runningTitle, description: guide.runningDescription),
    Faction.seiren => (title: guide.flexibilityTitle, description: guide.flexibilityDescription),
  };
}
