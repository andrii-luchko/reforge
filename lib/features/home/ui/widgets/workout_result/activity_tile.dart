import 'package:flutter/material.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({required this.activeDays, required this.totalDays, super.key});

  final int activeDays;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,

        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppSvgListTileIcon.asset(
            asset: Assets.images.icons.calendar2,
            color: appTheme.beige100,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
              Text(
                context.t.home.activity.active_days,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),

              Text(
                WeekDay.getTodayLabel(context) ?? '',
                style: subheadH6Regular.copyWith(color: appTheme.beige600),
              ),
            ],
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$activeDays', style: primaryStyle),
                TextSpan(text: ' / $totalDays', style: secondaryStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
