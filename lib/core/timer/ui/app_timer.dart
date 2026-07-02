import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/second_formatter.dart';
import 'package:reforge/core/timer/ui/smooth_timer_text.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppTimer extends StatelessWidget {
  const AppTimer({
    required this.totalSeconds,
    this.isPaused = false,
    super.key,
  });

  final int totalSeconds;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textStyle = subheadH3Medium.copyWith(color: appTheme.beige100);
    final formattedTime = formatSeconds(totalSeconds, alwaysShowHours: true);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme.beige900,
        border: GradientBoxBorder(gradient: appTheme.strokeTag),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        spacing: 16,
        children: [
          SmoothTimerText(
            formattedTime,
            style: textStyle,
          ),
          if (isPaused)
            SvgPicture.asset(
              width: 16,
              height: 16,
              Assets.images.icons.pause,
              colorFilter: ColorFilter.mode(appTheme.beige100, .srcIn),
            ),
        ],
      ),
    );
  }
}
