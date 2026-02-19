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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

bool _isYoutubeUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  return url.contains('youtube.com') || url.contains('youtu.be');
}

class AppVideoPlayer extends StatelessWidget {
  const AppVideoPlayer({
    required this.videoUrl,
    super.key,
  });

  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return const _VideoPlayerWrapper(
        child: VideoUnavailableWidget(),
      );
    }

    if (_isYoutubeUrl(videoUrl)) {
      return _YoutubeVideoPlayer(videoUrl: videoUrl!);
    }

    return _NativeVideoPlayer(videoUrl: videoUrl!);
  }
}

class _VideoPlayerWrapper extends StatelessWidget {
  const _VideoPlayerWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.beige900,
          border: Border.all(color: appTheme.strokeCard),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
}

class _YoutubeVideoPlayer extends StatefulWidget {
  const _YoutubeVideoPlayer({required this.videoUrl});

  final String videoUrl;

  @override
  State<_YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<_YoutubeVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null || videoId.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const _VideoPlayerWrapper(
        child: VideoUnavailableWidget(),
      );
    }

    if (_controller == null) {
      return const _VideoPlayerWrapper(
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return _VideoPlayerWrapper(
      child: YoutubePlayerBuilder(
        onExitFullScreen: () {
          unawaited(
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]),
          );
        },
        player: YoutubePlayer(
          controller: _controller!,
        ),
        builder: (context, player) => player,
      ),
    );
  }
}

class _NativeVideoPlayer extends StatefulWidget {
  const _NativeVideoPlayer({required this.videoUrl});

  final String videoUrl;

  @override
  State<_NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<_NativeVideoPlayer> with VideoPlayerControlsMixin {
  VideoPlayerController? _controller;

  bool _hasError = false;

  @override
  VideoPlayerController get controller => _controller!;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl.isNotEmpty) {
      _controller =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            )
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {
                      _hasError = false;
                    });
                    startHideTimer();
                  }
                })
                // ignore: inference_failure_on_untyped_parameter, discarded_futures
                .catchError((error) {
                  logger.e('Video initialization failed: $error');
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                    });
                  }
                });
    } else {
      _hasError = true;
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
        // ignore: discarded_futures
        .then((_) {
          unawaited(
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]),
          );
          unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
        });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.beige900,
          border: Border.all(color: appTheme.strokeCard),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError || (_controller != null && _controller!.value.hasError)) {
      return const VideoUnavailableWidget();
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return ValueListenableBuilder(
      valueListenable: _controller!,
      builder: (context, value, _) {
        if (value.hasError) return const VideoUnavailableWidget();

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
    );
  }
}
