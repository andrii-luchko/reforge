import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ContainedImageFrame extends StatelessWidget {
  const ContainedImageFrame({
    required this.imagePath,
    required this.originalImageSize,
    required this.builder,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  final String imagePath;
  final Size originalImageSize;
  final BorderRadius borderRadius;
  final Widget Function(BuildContext context, ContainedImageTransform transform) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final transform = ContainedImageTransform(
          canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
          imageSize: originalImageSize,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: transform.imageRect,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            builder(context, transform),
          ],
        );
      },
    );
  }
}

@immutable
class ContainedImageTransform {
  const ContainedImageTransform({
    required this.canvasSize,
    required this.imageSize,
  });

  final Size canvasSize;
  final Size imageSize;

  Rect get imageRect {
    final scale = math.min(canvasSize.width / imageSize.width, canvasSize.height / imageSize.height);
    final renderedSize = Size(imageSize.width * scale, imageSize.height * scale);
    final offset = Offset(
      (canvasSize.width - renderedSize.width) / 2,
      (canvasSize.height - renderedSize.height) / 2,
    );

    return offset & renderedSize;
  }

  Offset toCanvasOffset(Offset point) {
    final rect = imageRect;
    return Offset(
      rect.left + point.dx / imageSize.width * rect.width,
      rect.top + point.dy / imageSize.height * rect.height,
    );
  }

  Offset toImagePosition(Offset canvasPosition) {
    final rect = imageRect;
    return Offset(
      (canvasPosition.dx - rect.left) / rect.width * imageSize.width,
      (canvasPosition.dy - rect.top) / rect.height * imageSize.height,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContainedImageTransform && other.canvasSize == canvasSize && other.imageSize == imageSize;
  }

  @override
  int get hashCode => Object.hash(canvasSize, imageSize);
}
