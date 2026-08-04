import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/video_player/app_video_player.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({required this.videoUrl, super.key});

  final String? videoUrl;

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> with WidgetsBindingObserver {
  final GlobalKey _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final view = View.of(context);
    if (view.physicalSize.width > view.physicalSize.height) {
      _scrollToVideo();
    }
  }

  void _scrollToVideo() {
    final ctx = _videoKey.currentContext;
    if (ctx != null) {
      unawaited(
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          t.workout_instruction.videoInstructions,
          style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
        ),
        RepaintBoundary(
          key: _videoKey,
          child: AppVideoPlayer(
            videoUrl: widget.videoUrl,
          ),
        ),
      ],
    );
  }
}
