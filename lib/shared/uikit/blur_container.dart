import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  const BlurContainer({
    super.key,
    this.child,
    this.sigmaX = 5.0,
    this.sigmaY = 5.0,
    this.borderRadius,
  });

  final Widget? child;
  final double sigmaX;
  final double sigmaY;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        backdropGroupKey: BackdropKey(),
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
}
