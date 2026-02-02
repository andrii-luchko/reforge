import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/notched_faction_leaderboard_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/rhombus_painter.dart';
import 'package:reforge/features/leaderboard/ui/widgets/sparks.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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
              fillGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.53, 1.0],
                colors: [
                  Color(0x004A2105),
                  Color(0xFF4A2105),
                ],
              ),
              strokeGradient: appTheme.strokeTag,
            ),
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
                    mode == FactionMode.current ? 'Week $currentWeek / $totalWeeks' : 'Global',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    required this.firstFactionScore,
    required this.secondFactionScore,
    required this.winnerTitle,

    super.key,
  });

  final int firstFactionScore;
  final int secondFactionScore;
  final String winnerTitle;

  @override
  Widget build(BuildContext context) {
    final style = CardConfig.mainTextStyle.copyWith(
      color: context.appTheme.beige100,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        CustomPaint(
          painter: RhombusPainter(
            shadows: [
              const BoxShadow(
                color: Color(0xff4A2105),
                offset: Offset(2, 2),
                blurRadius: 20,
              ),
            ],
          ),
          child: SizedBox.fromSize(
            size: CardConfig.scoreBoxSize,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        firstFactionScore.toString(),
                        style: style,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: style.copyWith(color: context.appTheme.beige600),
                        ),
                      ),

                      Text(
                        secondFactionScore.toString(),
                        style: style,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,

          spacing: 4,
          children: [
            SvgPicture.asset(
              Assets.images.svg.trophy,
              height: CardConfig.trophySize,
            ),
            Text(
              '$winnerTitle win',
              style: CardConfig.thirtyTextStyle.copyWith(color: context.appTheme.beige100),
            ),
          ],
        ),
      ],
    );
  }
}

class FactionContainer extends StatelessWidget {
  const FactionContainer({
    required this.faction,
    required this.isUserFaction,
    this.isWinning = false,
    super.key,
  });

  final Faction faction;
  final bool isUserFaction;
  final bool isWinning;

  @override
  Widget build(BuildContext context) {
    final text = isUserFaction ? 'Your' : faction.title(t);

    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.fromSize(
          size: CardConfig.factionImageSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isWinning) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.appTheme.orange500,
                        blurRadius: 15,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],

              Center(
                child: RisingAuraEffect(
                  enabled: isWinning,
                  particleColor: context.appTheme.beige100,
                  particleCount: 30,
                  particleSize: 0.02,
                  child: FactionImage(faction: faction),
                ),
              ),
            ],
          ),
        ),

        Text(
          '$text faction',
          style: CardConfig.thirtyTextStyle.copyWith(
            color: context.appTheme.beige100,
          ),
        ),
      ],
    );
  }
}

class FactionImage extends StatelessWidget {
  const FactionImage({
    required this.faction,
    super.key,
  });

  final Faction faction;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: CardConfig.factionImageSize,
      child: Image.asset(faction.imageAssent()),
    );
  }
}
