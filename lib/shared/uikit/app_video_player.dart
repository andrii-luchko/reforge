import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> with VideoPlayerControlsMixin {
  late VideoPlayerController _controller;
  @override
  VideoPlayerController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(
              widget.videoUrl,
            ),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) {
            setState(() {});
            startHideTimer();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _enterFullScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => _FullScreenPlayer(controller: _controller),
          ),
        )
        .then((_) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Skeletonizer(
      enabled: !_controller.value.isInitialized,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: appTheme.beige900,
            border: Border.all(
              color: appTheme.strokeCard,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: toggleControls,
                  child: VideoPlayer(_controller),
                ),
                VideoControlsOverlay(
                  controller: _controller,
                  isVisible: showControls && _controller.value.isInitialized,
                  onPlayPause: togglePlay,
                  onFullscreen: _enterFullScreen,
                  onBackdropTap: toggleControls,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _FullScreenPlayer extends StatefulWidget {
  const _FullScreenPlayer({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<_FullScreenPlayer> with VideoPlayerControlsMixin {
  @override
  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    startHideTimer();
  }

  @override
  void dispose() {
    disposeControls();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: toggleControls,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
          VideoControlsOverlay(
            controller: widget.controller,
            isVisible: showControls,
            isFullScreen: true,
            onFullscreen: Navigator.of(context).pop,
            onPlayPause: togglePlay,
            onBackdropTap: toggleControls,
          ),
        ],
      ),
    );
  }
}

mixin VideoPlayerControlsMixin<T extends StatefulWidget> on State<T> {
  VideoPlayerController get controller;

  bool showControls = true;
  Timer? _hideTimer;

  void startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && controller.value.isPlaying) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });
    if (showControls) startHideTimer();
  }

  void togglePlay() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();

        showControls = true;
        _hideTimer?.cancel();
      } else {
        controller.play();

        startHideTimer();
      }
    });
  }

  void disposeControls() {
    _hideTimer?.cancel();
  }
}
