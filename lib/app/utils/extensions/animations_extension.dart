// ignore_for_file: avoid_returning_widgets
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimationsExtension on Widget {
  /// Standard appearance animation for lists and cards.
  ///
  /// [index] - if passed, adds a delay to create a stagger effect.
  /// [delay] - base delay before start.
  /// [isSlideUp] - if true (default), the element slides up from the bottom. Otherwise, it slides down from the top.
  ///
  Widget animateEntrance({
    int index = 0,
    Duration? delay,
    bool isSlideUp = true,
    double slideAmount = 0.1,
  }) {
    final staggerDelay = delay ?? (index * 10).ms;

    return animate(delay: staggerDelay)
        .fadeIn(
          duration: 300.ms,
          curve: Curves.easeOutQuad,
        )
        .slideY(
          begin: isSlideUp ? slideAmount : -slideAmount,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget animatePress() {
    return animate(target: 1).scaleXY(end: 0.95, duration: 100.ms, curve: Curves.easeInOut);
  }
}
