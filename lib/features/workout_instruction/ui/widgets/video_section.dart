import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/video_player/app_video_player.dart';

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
        AppVideoPlayer(
          videoUrl: videoUrl,
        ),
      ],
    );
  }
}
