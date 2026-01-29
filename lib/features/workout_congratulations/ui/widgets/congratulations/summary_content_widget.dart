import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/features/workout_common/models/workout_congratulations_content.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/staggered_summary_card.dart';

class SummaryContentWidget extends StatelessWidget {
  const SummaryContentWidget({
    required this.content,
    super.key,
  });

  final WorkoutSummaryContent content;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final items = <Widget>[];

    int itemNumber = 1;

    if (content.newLevel != null) {
      items.add(
        SummaryRowWidget(
          number: itemNumber++,
          title: t.workout_congratulations.new_level,
          tag: AppTag(text: '${content.newLevel} ${t.common.lv}'),
        ),
      );
    }

    items.add(
      SummaryRowWidget(
        number: itemNumber++,
        title: t.workout_congratulations.xp_earned,
        tag: Expanded(
          flex: 2,
          child: Row(
            spacing: 16,
            children: [
              Flexible(
                child: HorizontalXPBar(
                  progress: content.xpProgress ?? 0.2,
                ),
              ),
              Text(
                '+${content.xpEarned.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )} XP',
                style: subheadH8Semibold.copyWith(color: appTheme.beige100),
              ),
            ],
          ),
        ),
      ),
    );

    items.add(
      SummaryRowWidget(
        number: itemNumber++,
        title: t.workout_congratulations.duration,
        tag: AppTag(text: _formatDuration(content.timeSpent)),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        spacing: 32,
        children: [
          CenteredTitleSection(
            title: t.workout_congratulations.title,
            subtitle: t.workout_congratulations.subtitle,
          ),
          StaggeredSummaryCard(items: items),
        ],
      ),
    );
  }
}
