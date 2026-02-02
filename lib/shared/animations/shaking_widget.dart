import 'dart:async';

import 'package:flutter/material.dart';

class ShakingWidget extends StatefulWidget {
  const ShakingWidget({
    required this.child,
    super.key,
    this.shakeIntensity = 5.0,
    this.shakeDuration = const Duration(milliseconds: 1000),
    this.enabled = true,
  });

  final Widget child;
  final double shakeIntensity;
  final Duration shakeDuration;
  final bool enabled;

  @override
  State<ShakingWidget> createState() => _ShakingWidgetState();
}

class _ShakingWidgetState extends State<ShakingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.shakeDuration,
      vsync: this,
    );

    _animation =
        Tween<double>(
          begin: -widget.shakeIntensity,
          end: widget.shakeIntensity,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
    if (widget.enabled) {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _animation.value,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
