import 'package:flutter/material.dart';
import 'package:reforge/features/workout_common/models/workout_congratulations_content.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/sunrays_image_container.dart';

class AchievementContentWidget extends StatelessWidget {
  const AchievementContentWidget({
    required this.content,
    super.key,
  });

  final AchievementContent content;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 32,
        children: [
          SunRaysImageContainer.asset(
            asset: content.imageAsset,
          ),
          CenteredTitleSection(
            title: content.title,
            subtitle: content.description,
          ),
        ],
      ),
    );
  }
}
