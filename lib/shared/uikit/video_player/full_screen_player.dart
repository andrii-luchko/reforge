import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/shared/uikit/video_player/mixin/video_controls_mixin.dart';
import 'package:reforge/shared/uikit/video_player/video_controllers.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  const FullScreenPlayer({
    required this.controller,
    super.key,
  });

  final VideoPlayerController controller;

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> with VideoPlayerControlsMixin {
  @override
  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
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
