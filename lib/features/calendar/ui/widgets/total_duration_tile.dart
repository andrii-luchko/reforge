import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/int_extension.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';

class TotalDurationTile extends StatelessWidget {
  const TotalDurationTile({required this.trainingDuration, super.key});

  final int trainingDuration;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);
    final duration = trainingDuration.durationFormatted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: Row(
        children: [
          AppSvgListTileIcon(
            asset: Assets.images.icons.timer,
            color: appTheme.beige100,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  t.home.activity.total_duration,
                  style: subheadH3Medium.copyWith(color: appTheme.beige100),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${duration.hours}', style: primaryStyle),
                      TextSpan(
                        text: ' ${context.t.timer.hours_short} ',
                        style: secondaryStyle,
                      ),
                      TextSpan(text: '${duration.minutes}', style: primaryStyle),
                      TextSpan(
                        text: ' ${context.t.timer.minutes_short}',
                        style: secondaryStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
