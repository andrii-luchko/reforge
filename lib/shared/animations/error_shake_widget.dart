import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class ErrorShakeWidget extends StatelessWidget {
  const ErrorShakeWidget({required this.shake, super.key, this.error});

  final bool shake;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      shake: shake,
      child: AnimatedOpacity(
        opacity: error == null ? 0 : 1,
        duration: Durations.medium2,
        child: Text(
          error ?? '',
          style: bodyLRegular.copyWith(color: context.appTheme.red400),
        ),
      ),
    );
  }
}

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    required this.child,
    this.shake = false,
    super.key,
  });

  final Widget child;
  final bool shake;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shake) {
      unawaited(_controller.forward(from: 0));
      unawaited(HapticFeedback.lightImpact());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        final offset = sin(progress * pi * 4) * 8 * (1 - progress);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
