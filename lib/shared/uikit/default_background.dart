import 'package:flutter/material.dart';

import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class DefaultBackground extends StatelessWidget {
  const DefaultBackground({
    required this.body,
    this.loader,
    this.additionalAnimationsBehind = const [],
    this.additionalAnimationsOnTop = const [],
    this.additionalWidgetsAfterBody = const [],
    this.isExpanded = true,
    super.key,
  });

  final Widget body;
  final Positioned? loader;
  final List<Widget> additionalAnimationsBehind;
  final List<Widget> additionalAnimationsOnTop;
  final List<Widget> additionalWidgetsAfterBody;
  final bool isExpanded;
  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        ...additionalAnimationsBehind,
        Positioned.fill(
          child: Image.asset(
            Assets.images.png.smoke.path,
            fit: .fill,
            opacity: const AlwaysStoppedAnimation<double>(0.2),
          ),
        ),

        Positioned.fill(
          child: Image.asset(
            Assets.images.png.noiseAndTexture.path,
            fit: .fill,
          ),
        ),
        ...additionalAnimationsOnTop,
        body,
        ...additionalWidgetsAfterBody,
        ?loader,
      ],
    );
    return isExpanded ? SizedBox.expand(child: child) : child;
  }
}
