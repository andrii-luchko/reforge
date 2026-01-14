import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/shared/uikit/video_player/full_screen_player.dart';
import 'package:reforge/shared/uikit/video_player/mixin/video_controls_mixin.dart';
import 'package:reforge/shared/uikit/video_player/video_controllers.dart';
import 'package:reforge/shared/uikit/video_player/video_unavailable.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    required this.videoUrl,
    super.key,
  });

  final String? videoUrl;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> with VideoPlayerControlsMixin {
  VideoPlayerController? _controller;

  @override
  VideoPlayerController get controller => _controller!;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl!),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            )
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {});

                    startHideTimer();
                  }
                })
                // ignore: inference_failure_on_untyped_parameter, discarded_futures
                .catchError((error) {
                  logger.e('Video initialization failed: $error');

                  if (mounted) setState(() => _controller = null);
                });
    }
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    disposeControls();
    super.dispose();
  }

  void _enterFullScreen() {
    if (_controller == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FullScreenPlayer(controller: _controller!),
          ),
        )
        .then((_) {
          unawaited(SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]));
          unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
        });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final isReady = _controller != null && _controller!.value.isInitialized && !_controller!.value.hasError;

    return AspectRatio(
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
          child: !isReady
              ? const VideoUnavailableWidget()
              : ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, controller, _) {
                    if (controller.hasError) return const VideoUnavailableWidget();

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: toggleControls,
                          child: VideoPlayer(_controller!),
                        ),
                        VideoControlsOverlay(
                          controller: _controller!,
                          isVisible: showControls,
                          onPlayPause: togglePlay,
                          onFullscreen: _enterFullScreen,
                          onBackdropTap: toggleControls,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
