import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/faction_container.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/score_widget.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/notched_faction_leaderboard_card.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardConfig {
  static const double width = 358;
  static const double height = 196;

  static const double innerCardWidth = 400;
  static const double innerCardHeight = 156;

  static const EdgeInsets innerPadding = EdgeInsets.only(left: 12, right: 12, top: 48, bottom: 16);

  static const Size factionImageSize = Size(77.59, 90);
  static const Size factionAnimationSize = Size(30, 90);
  static const Size scoreBoxSize = Size(100, 45);
  static const double trophySize = 14;

  static const TextStyle mainTextStyle = subheadH1Medium;
  static final TextStyle headerTextStyle = subheadH8Semibold.copyWith(fontSize: 13);
  static const TextStyle secondaryTextStyle = subheadH8Semibold;
  static const TextStyle thirtyTextStyle = subheadH8Semibold;
}

class FactionLeaderboardCardShimmer extends StatelessWidget {
  const FactionLeaderboardCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FactionCardClipper(),
      child: const Bone(
        height: CardConfig.height,
        width: CardConfig.width,
      ),
    );
  }
}

class FactionLeaderboardCardError extends StatelessWidget {
  const FactionLeaderboardCardError({super.key});

  @override
  Widget build(BuildContext context) {
    return _FactionLeaderboardCardBase(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.signal_wifi_off_rounded,
                color: context.appTheme.beige700,
                size: 32,
              ),
              const SizedBox(height: 12),

              Text(
                'Battlefield Intel Unavailable',
                textAlign: TextAlign.center,
                style: subheadH2Medium.copyWith(
                  color: context.appTheme.beige100,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Check your connection or try again later',
                textAlign: TextAlign.center,
                style: subheadH8Semibold.copyWith(
                  color: context.appTheme.beige700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FactionLeaderboardCard extends StatelessWidget {
  const FactionLeaderboardCard({
    required this.firstFaction,
    required this.secondFaction,

    required this.mode,
    required this.userFaction,
    required this.totalWeeks,
    required this.currentWeek,
    super.key,
  });

  final FactionMode mode;
  final LeaderboardFactionModel firstFaction;
  final LeaderboardFactionModel secondFaction;
  final Faction userFaction;
  final int totalWeeks;
  final int currentWeek;

  String _getHeaderMessage(Translations t) {
    final firstScore = firstFaction.scoreByMode(mode);
    final secondScore = secondFaction.scoreByMode(mode);

    if (firstScore == secondScore) {
      return 'It’s a tie! Break the deadlock!';
    }

    final isUserWinning =
        (firstFaction.faction == userFaction && firstScore > secondScore) ||
        (secondFaction.faction == userFaction && firstScore > secondScore);

    return isUserWinning ? 'Keep it up - your faction is winning!' : 'Your faction needs you - push stronger!';
  }

  @override
  Widget build(BuildContext context) {
    final firstScore = firstFaction.scoreByMode(mode);
    final secondScore = secondFaction.scoreByMode(mode);

    final isFirstWinning = firstScore > secondScore;
    final isSecondWinning = secondScore > firstScore;

    return _FactionLeaderboardCardBase(
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.8),
            child: Text(
              _getHeaderMessage(t),
              style: CardConfig.headerTextStyle.copyWith(
                color: context.appTheme.beige100,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              mode == FactionMode.currentFight ? 'Week $currentWeek / $totalWeeks' : 'Global',
              style: CardConfig.secondaryTextStyle.copyWith(
                color: context.appTheme.beige700,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: CardConfig.innerPadding,
              child: CustomPaint(
                size: const Size(CardConfig.innerCardWidth, CardConfig.innerCardHeight),
                painter: NotchedFactionLeaderboardCard(
                  strokeGradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFC66C32),
                      Color(0x43C66D32),
                    ],
                  ),
                ),
                child: SizedBox(
                  width: CardConfig.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FactionContainer(
                            faction: firstFaction.faction,
                            isUserFaction: firstFaction.faction == userFaction,
                            isWinning: isFirstWinning,
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _VictoryPointsGuideTarget(
                              child: ScoreWidget(
                                firstFactionScore: firstScore,
                                secondFactionScore: secondScore,
                                winnerTitle: firstScore == secondScore
                                    ? 'No leader'
                                    : (firstScore > secondScore
                                          ? firstFaction.faction.title(t)
                                          : secondFaction.faction.title(t)),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: FactionContainer(
                            faction: secondFaction.faction,
                            isUserFaction: secondFaction.faction == userFaction,
                            isWinning: isSecondWinning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VictoryPointsGuideTarget extends StatelessWidget {
  const _VictoryPointsGuideTarget({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final guide = context.read<FactionWarsGuide?>();
    if (guide == null) return child;

    return GuideTarget(
      anchor: guide.anchor(FactionWarsGuideStep.victoryPoints),
      scope: leaderboardPageGuideScope,
      tooltip: guide.tooltip(FactionWarsGuideStep.victoryPoints),
      targetPadding: const EdgeInsets.all(16).copyWith(top: 0),
      child: child,
    );
  }
}

class _FactionLeaderboardCardBase extends StatelessWidget {
  const _FactionLeaderboardCardBase({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AspectRatio(
      aspectRatio: CardConfig.width / CardConfig.height,
      child: FittedBox(
        child: SizedBox(
          width: CardConfig.width,
          height: CardConfig.height,
          child: CustomPaint(
            painter: NotchedFactionLeaderboardCard(
              backgroundColor: appTheme.beige900,
              fillGradient: appTheme.factionCardFillGradient,
              strokeGradient: appTheme.strokeTag,
              drawStroke: false,
            ),
            foregroundPainter: NotchedFactionLeaderboardCard(
              strokeGradient: appTheme.strokeTag,
              drawFill: false,
            ),
            child: ClipPath(
              clipper: FactionCardClipper(),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
