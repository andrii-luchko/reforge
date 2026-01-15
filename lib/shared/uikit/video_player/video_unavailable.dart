import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class VideoUnavailableWidget extends StatelessWidget {
  const VideoUnavailableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 16,
      children: [
        const AppIconButton.icon(
          iconData: Icons.videocam_off_rounded,
        ),
        Text(
          'Video Unavailable',
          style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
        ),
      ],
    );
  }
}
