import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/gradient_line.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class FactionLeaderboardModePiker extends StatelessWidget {
  const FactionLeaderboardModePiker({required this.onModeChanged, required this.selectedMode, super.key});

  final ValueChanged<FactionMode> onModeChanged;
  final FactionMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      children: [
        const GradientLine(
          width: double.infinity,
        ),

        const SizedBox(
          height: 24,
        ),

        Row(
          mainAxisAlignment: .spaceEvenly,
          children: FactionMode.values
              .map(
                (e) => GestureDetector(
                  onTap: () => onModeChanged(e),
                  child: Text(
                    e.title(t),
                    style: subheadH3Medium.copyWith(
                      color: selectedMode == e ? context.appTheme.beige100 : context.appTheme.beige700,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                    textAlign: .center,
                  ),
                ).animatePress(),
              )
              .toList(),
        ),

        const SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
