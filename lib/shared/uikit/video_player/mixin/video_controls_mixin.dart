import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
        unawaited(controller.pause());

        showControls = true;
        _hideTimer?.cancel();
      } else {
        unawaited(controller.play());

        startHideTimer();
      }
    });
  }

  void disposeControls() {
    _hideTimer?.cancel();
  }
}
