// ignore_for_file: prefer_match_file_name
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/summary_content_widget.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/sunrays_image_container.dart';

class AchievementShareContent extends StatelessWidget {
  const AchievementShareContent({
    required this.imageUrl,
    required this.title,
    required this.description,
    super.key,
  });

  final String? imageUrl;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageUrl == null)
          SunRaysImageContainer.asset(
            reyLength: 0.07,
            width: 150,
            height: 150,
            asset: Assets.images.png.badge.path,
          )
        else
          SunRaysImageContainer.network(
            reyLength: 0.07,
            width: 150,
            height: 150,
            url: imageUrl!,
          ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8),
          child: CenteredTitleSection(
            title: title,
            subtitle: description,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class SummaryShareContent extends StatelessWidget {
  const SummaryShareContent({
    required this.newLevel,
    required this.xpEarned,
    required this.timeSpentSec,
    required this.xpProgress,
    super.key,
  });

  final int? newLevel;
  final double xpProgress;
  final int xpEarned;
  final int timeSpentSec;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 32,
      children: [
        Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 3,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: appTheme.beige900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appTheme.strokeCard),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                Assets.images.png.foreground512x512.path,
              ),
            ),
          ),
        ),
        CenteredTitleSection(
          title: t.workout_congratulations.share_summary_title,
          subtitle: t.workout_congratulations.share_summary_subtitle,
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            child: SizedBox(
              width: 400,
              child: WorkoutSummaryStatsCard(
                newLevel: newLevel,
                xpProgress: xpProgress,
                xpEarned: xpEarned,
                timeSpentSec: timeSpentSec,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
