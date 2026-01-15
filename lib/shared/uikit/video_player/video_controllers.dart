import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:video_player/video_player.dart';

class VideoControlsOverlay extends StatelessWidget {
  const VideoControlsOverlay({
    required this.controller,
    required this.isVisible,
    required this.onPlayPause,
    required this.onBackdropTap,
    required this.onFullscreen,
    this.isFullScreen = false,
    super.key,
  });

  final VideoPlayerController controller;
  final bool isVisible;
  final bool isFullScreen;
  final VoidCallback onPlayPause;
  final VoidCallback onBackdropTap;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onBackdropTap,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: onPlayPause,
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, value, child) => AppIconButton(
                      iconAsset: value.isPlaying ? Assets.images.icons.pause : Assets.images.icons.play,
                      onPressed: onPlayPause,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 2,
              right: 10,

              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: context.appTheme.orange300,
                            bufferedColor: context.appTheme.beige200,
                            backgroundColor: context.appTheme.beige100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      AppIconButton.icon(
                        width: isFullScreen ? 48 : 36,
                        height: isFullScreen ? 48 : 36,
                        iconSize: isFullScreen ? 32 : 18,
                        iconData: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        onPressed: onFullscreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
