import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/activity_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({
    required this.stats,
    super.key,
  });

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);

    final duration = stats.durationFormatted;

    return Column(
      children: [
        Row(
          children: [
            _ActivityCard(
              icon: Assets.images.icons.timer,
              title: 'Total Duration',
              content: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${duration.hours}', style: primaryStyle),
                    TextSpan(text: ' h ', style: secondaryStyle),

                    TextSpan(text: '${duration.minutes}', style: primaryStyle),
                    TextSpan(text: ' m', style: secondaryStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            _ActivityCard(
              icon: Assets.images.icons.dumbbell,
              title: 'Workouts',
              content: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${stats.workoutsCount}', style: primaryStyle),
                    TextSpan(text: ' / sessions', style: secondaryStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ActivityTile(
          activeDays: stats.activeDays,
          totalDays: stats.totalDays,
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final String icon;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.beige900,
          border: Border.all(color: appTheme.strokeCard),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconButton(iconAsset: icon),
            const SizedBox(height: 20),
            Text(title, style: subheadH3Medium.copyWith(color: appTheme.beige100)),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}
