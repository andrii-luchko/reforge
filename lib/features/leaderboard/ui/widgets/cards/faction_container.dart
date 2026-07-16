import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/faction_leaderboard_card.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/rising_aura_effect.dart';

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

        FittedBox(
          child: Text(
            '$text faction',
            maxLines: 1,
            overflow: .ellipsis,
            textAlign: .center,
            style: CardConfig.thirtyTextStyle.copyWith(
              color: context.appTheme.beige100,
            ),
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
