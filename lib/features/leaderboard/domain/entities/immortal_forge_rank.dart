import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

enum ImmortalForgeRank {
  daizosho(rank: 1, apiRole: 'artificer', title: 'Daizōshō'),
  might(rank: 2, apiRole: 'might', title: 'Might'),
  judgement(rank: 3, apiRole: 'judgement', title: 'Judgement'),
  strife(rank: 4, apiRole: 'strife', title: 'Strife'),
  burden(rank: 5, apiRole: 'burden', title: 'Burden');

  const ImmortalForgeRank({
    required this.rank,
    required this.apiRole,
    required this.title,
  });

  final int rank;
  final String apiRole;
  final String title;

  static ImmortalForgeRank? fromRank(int rank) {
    for (final value in values) {
      if (value.rank == rank) return value;
    }
    return null;
  }

  Gradient gradient(BuildContext context) {
    switch (this) {
      case ImmortalForgeRank.daizosho:
        return context.appTheme.goldGradient;
      case ImmortalForgeRank.might:
        return context.appTheme.silverGradient;
      case ImmortalForgeRank.judgement:
        return context.appTheme.bronzeGradient;
      case ImmortalForgeRank.strife:
        return context.appTheme.ironGradient;
      case ImmortalForgeRank.burden:
        return context.appTheme.steelGradient;
    }
  }
}

extension ImmortalForgeRankLookup on int {
  String get immortalForgeTitle => ImmortalForgeRank.fromRank(this)?.title ?? 'Soldier';

  Gradient immortalForgeGradient(BuildContext context) =>
      ImmortalForgeRank.fromRank(this)?.gradient(context) ?? context.appTheme.woodGradient;
}
