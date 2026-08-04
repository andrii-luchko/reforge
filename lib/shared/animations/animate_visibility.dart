import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
  const AnimatedVisibility({
    required this.child,
    required this.isVisible,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeInOut,
    super.key,
  });

  final Widget child;
  final bool isVisible;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      child: isVisible
          ? AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: 1,
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}
