import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PressableAnimation extends StatefulWidget {
  const PressableAnimation({required this.child, this.onTap, this.scaleAmount = 0.95, super.key});

  final Widget child;
  final VoidCallback? onTap;
  final double scaleAmount;
  @override
  State<PressableAnimation> createState() => _PressableAnimationState();
}

class _PressableAnimationState extends State<PressableAnimation> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          unawaited(HapticFeedback.lightImpact());
        }
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child
          .animate(target: _isPressed ? 1 : 0)
          .scaleXY(
            end: widget.scaleAmount,
            duration: 100.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
