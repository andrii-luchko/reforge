// ignore_for_file: prefer_match_file_name
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/sunrays_image_container.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/staggered_summary_card.dart';

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
        CenteredTitleSection(
          title: title,
          subtitle: description,
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
  final double? xpProgress;
  final int xpEarned;

  final int timeSpentSec;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final items = <Widget>[];

    var itemNumber = 1;

    if (newLevel != null) {
      items.add(
        SummaryRowWidget(
          number: itemNumber++,
          title: t.workout_congratulations.new_level,
          tag: AppTag(text: '$newLevel ${t.common.lv}'),
        ),
      );
    }

    items
      ..add(
        SummaryRowWidget(
          number: itemNumber++,
          title: t.workout_congratulations.xp_earned,
          tag: Expanded(
            flex: 2,
            child: Row(
              spacing: 8,
              children: [
                Flexible(
                  child: HorizontalXPBar(
                    progress: xpProgress ?? 0.2,
                  ),
                ),
                Text(
                  '+${xpEarned.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )} XP',
                  style: subheadH8Semibold.copyWith(color: appTheme.beige100),
                ),
              ],
            ),
          ),
        ),
      )
      ..add(
        SummaryRowWidget(
          number: itemNumber++,
          title: t.workout_congratulations.duration,
          tag: AppTag(text: _formatDuration(Duration(seconds: timeSpentSec))),
        ),
      );

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
              child: StaggeredSummaryCard(items: items),
            ),
          ),
        ),
      ],
    );
  }
}
