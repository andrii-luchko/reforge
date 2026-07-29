import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/gradient_line.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/painters/gas_painter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FactionLeaderboardModePiker extends StatelessWidget {
  const FactionLeaderboardModePiker({required this.onModeChanged, required this.selectedMode, super.key});

  final ValueChanged<FactionMode> onModeChanged;
  final FactionMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: -70,
          child: Skeleton.ignore(
            child: GasWidget(
              color: context.appTheme.orange400,
              size: const Size.square(130),
              blurRadius: 45,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            spacing: 24,
            children: [
              const Skeleton.ignore(
                child: GradientLine(
                  width: double.infinity,
                ),
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
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
