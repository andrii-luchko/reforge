import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/pose_angle_calculator.dart';

class PoseDetectionImage extends StatefulWidget {
  const PoseDetectionImage({
    required this.imagePath,
    required this.originalImageSize,
    required this.points,
    required this.angle,
    required this.onPointMoved,
    this.onInteractionStart,
    this.onInteractionEnd,
    super.key,
  });

  final String imagePath;
  final Size originalImageSize;
  final List<PoseDataPoint> points;
  final double angle;
  final void Function(int pointNumber, Offset position) onPointMoved;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;

  @override
  State<PoseDetectionImage> createState() => _PoseDetectionImageState();
}

class _PoseDetectionImageState extends State<PoseDetectionImage> {
  final Map<int, int> _activePointerToPoint = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final transform = _PoseImageTransform(
          canvasSize: size,
          imageSize: widget.originalImageSize,
        );

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _onPointerDown(event, transform),
          onPointerMove: (event) => _onPointerMove(event, transform),
          onPointerUp: _clearPointer,
          onPointerCancel: _clearPointer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              CustomPaint(
                painter: _PoseDetectionPainter(
                  points: widget.points,
                  angle: widget.angle,
                  transform: transform,
                  theme: context.appTheme,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPointerDown(PointerDownEvent event, _PoseImageTransform transform) {
    final point = _findNearestPoint(event.localPosition, transform);
    if (point == null || _activePointerToPoint.containsValue(point.number)) return;

    final shouldNotifyStart = _activePointerToPoint.isEmpty;
    _activePointerToPoint[event.pointer] = point.number;

    if (shouldNotifyStart) {
      widget.onInteractionStart?.call();
    }
  }

  void _onPointerMove(PointerMoveEvent event, _PoseImageTransform transform) {
    final pointNumber = _activePointerToPoint[event.pointer];
    if (pointNumber == null) return;

    final imagePosition = transform.toImagePosition(event.localPosition);
    final clampedPosition = Offset(
      imagePosition.dx.clamp(0, widget.originalImageSize.width).toDouble(),
      imagePosition.dy.clamp(0, widget.originalImageSize.height).toDouble(),
    );

    widget.onPointMoved(pointNumber, clampedPosition);
  }

  void _clearPointer(PointerEvent event) {
    _activePointerToPoint.remove(event.pointer);

    if (_activePointerToPoint.isEmpty) {
      widget.onInteractionEnd?.call();
    }
  }

  PoseDataPoint? _findNearestPoint(Offset position, _PoseImageTransform transform) {
    const hitRadius = 34.0;
    PoseDataPoint? nearest;
    var nearestDistance = double.infinity;

    for (final point in widget.points) {
      final pointPosition = transform.toCanvasPosition(point);
      final distance = (pointPosition - position).distance;

      if (distance < hitRadius && distance < nearestDistance) {
        nearest = point;
        nearestDistance = distance;
      }
    }

    return nearest;
  }
}

class _PoseDetectionPainter extends CustomPainter {
  const _PoseDetectionPainter({
    required this.points,
    required this.angle,
    required this.transform,
    required this.theme,
  });

  final List<PoseDataPoint> points;
  final double angle;
  final _PoseImageTransform transform;
  final AppTheme theme;

  static const _connections = [
    ('head', 'left_shoulder'),
    ('head', 'right_shoulder'),
    ('left_shoulder', 'right_shoulder'),
    ('left_shoulder', 'left_pelvis'),
    ('right_shoulder', 'right_pelvis'),
    ('left_pelvis', 'right_pelvis'),
    ('left_pelvis', 'left_knee'),
    ('right_pelvis', 'right_knee'),
    ('left_knee', 'left_foot'),
    ('right_knee', 'right_foot'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pointsByName = {for (final point in points) point.name: point};
    final skeletonPaint = Paint()
      ..color = theme.orange400
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final anglePaint = Paint()
      ..color = theme.beige100
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final connection in _connections) {
      final start = pointsByName[connection.$1];
      final end = pointsByName[connection.$2];
      if (start == null || end == null) continue;

      canvas.drawLine(
        transform.toCanvasPosition(start),
        transform.toCanvasPosition(end),
        skeletonPaint,
      );
    }

    _drawAngleLines(canvas, pointsByName, anglePaint);
    _drawPoints(canvas);
    _drawAngleLabel(canvas, pointsByName);
  }

  void _drawAngleLines(Canvas canvas, Map<String, PoseDataPoint> pointsByName, Paint paint) {
    final first = pointsByName[PoseAngleCalculator.firstPointName];
    final vertex = pointsByName[PoseAngleCalculator.vertexPointName];
    final second = pointsByName[PoseAngleCalculator.secondPointName];

    if (first == null || vertex == null || second == null) return;

    final vertexPosition = transform.toCanvasPosition(vertex);
    canvas
      ..drawLine(vertexPosition, transform.toCanvasPosition(first), paint)
      ..drawLine(vertexPosition, transform.toCanvasPosition(second), paint);
  }

  void _drawPoints(Canvas canvas) {
    final fillPaint = Paint()..color = theme.orange500;
    final lowConfidencePaint = Paint()
      ..color = theme.beige100
      ..style = PaintingStyle.stroke;
    final borderPaint = Paint()
      ..color = theme.beige100.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final crossPaint = Paint()
      ..color = theme.beige100
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (final point in points) {
      final center = transform.toCanvasPosition(point);
      canvas
        ..drawCircle(center, 16, fillPaint)
        ..drawCircle(center, 17, borderPaint);

      if (point.isLowConfidence) {
        canvas.drawCircle(center, 21, lowConfidencePaint);
      }

      canvas
        ..drawLine(center.translate(-7, 0), center.translate(7, 0), crossPaint)
        ..drawLine(center.translate(0, -7), center.translate(0, 7), crossPaint);
    }
  }

  void _drawAngleLabel(Canvas canvas, Map<String, PoseDataPoint> pointsByName) {
    final vertex = pointsByName[PoseAngleCalculator.vertexPointName];
    if (vertex == null) return;

    final position = transform.toCanvasPosition(vertex).translate(34, -25);
    (TextPainter(
      text: TextSpan(
        text: '${angle.round()}°',
        style: subheadH2Medium.copyWith(color: theme.beige100),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _PoseDetectionPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.angle != angle ||
        oldDelegate.transform != transform ||
        oldDelegate.theme != theme;
  }
}

@immutable
class _PoseImageTransform {
  const _PoseImageTransform({
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

  Offset toCanvasPosition(PoseDataPoint point) {
    final rect = imageRect;
    return Offset(
      rect.left + point.x / imageSize.width * rect.width,
      rect.top + point.y / imageSize.height * rect.height,
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
    return other is _PoseImageTransform && other.canvasSize == canvasSize && other.imageSize == imageSize;
  }

  @override
  int get hashCode => Object.hash(canvasSize, imageSize);
}
