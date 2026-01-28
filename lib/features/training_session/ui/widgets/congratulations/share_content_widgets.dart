import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/ui/widgets/xp_tile.dart';
import 'package:reforge/features/training_session/data/models/workout_congratulations_content.dart';
import 'package:reforge/features/training_session/domain/enums/tier.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/sunrays_image_container.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/glass_container.dart';
import 'package:reforge/shared/uikit/staggered_summary_card.dart';

class RankCardShareContent extends StatelessWidget {
  const RankCardShareContent({
    required this.content,
    super.key,
  });

  final RankCardContent content;

  @override
  Widget build(BuildContext context) {
    final tierTitle = content.tier.title(t);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.workout_congratulations.share_rank_message,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: FittedBox(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: AvatarCard(
                faction: content.faction,
                lvl: content.level,
                rankName: tierTitle,
                xpValue: content.xpProgress,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Share content for achievement
class AchievementShareContent extends StatelessWidget {
  const AchievementShareContent({
    required this.content,
    super.key,
  });

  final AchievementContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SunRaysImageContainer.asset(
          asset: content.imageAsset,
          reyLength: 0.07,
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 16),
        CenteredTitleSection(
          title: content.title,
          subtitle: content.description,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Share content for default summary
class SummaryShareContent extends StatelessWidget {
  const SummaryShareContent({
    required this.content,
    super.key,
  });

  final WorkoutSummaryContent content;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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
            spacing: 8,
            children: [
              Flexible(
                child: HorizontalXPBar(
                  progress: content.xpProgress ?? 0.0,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SunRaysImageContainer.asset(
          asset: Assets.images.png.badge.path,
          reyLength: 0.07,
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 16),
        CenteredTitleSection(
          title: t.workout_congratulations.share_summary_title,
          subtitle: t.workout_congratulations.share_summary_subtitle,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            fit: BoxFit.contain,
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
