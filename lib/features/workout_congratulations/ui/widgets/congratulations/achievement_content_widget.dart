import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';

import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import 'package:reforge/shared/sunrays_image_container.dart';

class AchievementContentWidget extends StatelessWidget {
  const AchievementContentWidget({
    required this.milestone,
    super.key,
  });

  final UserWorkoutMilestoneEntity milestone;

  @override
  Widget build(BuildContext context) {
    final imageUrl = milestone.iconUrl;
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      height: 1.5,
      color: context.appTheme.beige600,
    );

    final accentStyle = baseStyle?.copyWith(
      color: context.appTheme.beige100,
      fontWeight: FontWeight.w900,
    );

    return SingleChildScrollView(
      child: Column(
        spacing: 32,
        children: [
          if (imageUrl == null)
            SunRaysImageContainer.asset(
              asset: Assets.images.png.badge.path,
            )
          else
            SunRaysImageContainer.network(
              url: imageUrl,
            ),

          Text(
            t.workout_congratulations.milestone_unlocked_title,
            style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
          ),
          Text.rich(
            t.workout_congratulations.milestone_unlocked_subtitle(
              Name: (text) => TextSpan(
                text: milestone.name,
                style: accentStyle,
              ),
              Tier: (text) => TextSpan(
                text: milestone.tier.toString(),
                style: accentStyle,
              ),
            ),
            textAlign: TextAlign.center,

            style: baseStyle,
          ),
        ],
      ),
    );
  }
}
