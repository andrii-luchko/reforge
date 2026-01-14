import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/ui/widgets/app_tags_list_view.dart';

import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/app_video_player.dart';

import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutInstructionPage extends StatelessWidget {
  const WorkoutInstructionPage({required this.name, required this.workoutId, super.key});

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              name,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: WorkoutInstructionBody()),
    );
  }
}

class WorkoutInstructionBody extends StatelessWidget {
  const WorkoutInstructionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const VideoSection(
                videoUrl: null,
              ),
              const SizedBox(height: 16),

              AppTagsListView(tags: ['10 reps', 'xp 1200', 'Duration 15 min']),

              const SizedBox(height: 32),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoSection extends StatelessWidget {
  const VideoSection({required this.videoUrl, super.key});

  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        Text(
          'Video instructions',
          style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
        ),
        if (videoUrl != null)
          AppVideoPlayer(
            videoUrl: videoUrl!,
          )
        else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.appTheme.beige900,
                border: Border.all(
                  color: context.appTheme.strokeCard,
                ),
              ),
              child: Center(
                child: Text(
                  'No video available',
                  style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
