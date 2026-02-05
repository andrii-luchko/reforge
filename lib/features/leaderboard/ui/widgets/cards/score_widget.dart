import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/faction_leaderboard_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/painters/rhombus_painter.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

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
            Flexible(
              child: Text(
                '$winnerTitle win',
                style: CardConfig.thirtyTextStyle.copyWith(color: context.appTheme.beige100),

                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
