import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PressableAnimation extends StatefulWidget {
  const PressableAnimation({
    this.child,
    this.builder,
    this.onTap,
    this.scaleAmount = 0.95,
    this.enabledFeedback = true,
    this.behavior = .opaque,
    super.key,
  }) : assert(child != null || builder != null, 'Either child or builder must be provided');

  final Widget? child;
  final Widget Function(BuildContext context, {required bool isPressed})? builder;
  final VoidCallback? onTap;
  final double scaleAmount;
  final bool enabledFeedback;
  final HitTestBehavior? behavior;

  @override
  State<PressableAnimation> createState() => _PressableAnimationState();
}

class _PressableAnimationState extends State<PressableAnimation> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.builder != null ? widget.builder!(context, isPressed: _isPressed) : widget.child!;

    if (widget.onTap == null) return content;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null && widget.enabledFeedback) {
          unawaited(HapticFeedback.lightImpact());
        }
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: widget.behavior,
      child: content
          .animate(target: _isPressed ? 1 : 0)
          .scaleXY(
            end: widget.scaleAmount,
            duration: 100.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
