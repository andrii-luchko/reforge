import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_point_name.dart';
import 'package:reforge/features/camera_detection/domain/pose_angle_calculator.dart';
import 'package:reforge/features/camera_detection/ui/widgets/contained_image_frame.dart';

class PoseDetectionImage extends StatefulWidget {
  const PoseDetectionImage({
    required this.imagePath,
    required this.originalImageSize,
    required this.points,
    required this.angleResult,
    required this.onPointMoved,
    this.onInteractionStart,
    this.onInteractionEnd,
    super.key,
  });

  final String imagePath;
  final Size originalImageSize;
  final List<PoseDataPoint> points;
  final PoseAngleResult? angleResult;
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
    return ContainedImageFrame(
      imagePath: widget.imagePath,
      originalImageSize: widget.originalImageSize,
      builder: (context, transform) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => _onPointerDown(event, transform),
              onPointerMove: (event) => _onPointerMove(event, transform),
              onPointerUp: _clearPointer,
              onPointerCancel: _clearPointer,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _PoseLinesPainter(
                      angleResult: widget.angleResult,
                      transform: transform,
                      theme: context.appTheme,
                    ),
                  ),
                  ..._derivedPointMarkers(transform),
                  ..._pointMarkers(transform),
                  ?_angleLabel(transform, context.appTheme),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPointerDown(PointerDownEvent event, ContainedImageTransform transform) {
    final point = _findNearestPoint(event.localPosition, transform);
    if (point == null || _activePointerToPoint.containsValue(point.number)) return;

    final shouldNotifyStart = _activePointerToPoint.isEmpty;
    setState(() {
      _activePointerToPoint[event.pointer] = point.number;
    });

    if (shouldNotifyStart) {
      widget.onInteractionStart?.call();
    }
  }

  void _onPointerMove(PointerMoveEvent event, ContainedImageTransform transform) {
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
    if (!_activePointerToPoint.containsKey(event.pointer)) return;

    setState(() {
      _activePointerToPoint.remove(event.pointer);
    });

    if (_activePointerToPoint.isEmpty) {
      widget.onInteractionEnd?.call();
    }
  }

  PoseDataPoint? _findNearestPoint(Offset position, ContainedImageTransform transform) {
    final angleResult = widget.angleResult;
    if (angleResult == null) return null;

    const hitRadius = 34.0;
    PoseDataPoint? nearest;
    var nearestDistance = double.infinity;

    for (final point in widget.points) {
      if (!angleResult.editablePointNames.contains(point.name)) continue;

      final pointPosition = _toCanvasPosition(transform, point);
      final distance = (pointPosition - position).distance;

      if (distance < hitRadius && distance < nearestDistance) {
        nearest = point;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  List<Widget> _pointMarkers(ContainedImageTransform transform) {
    final angleResult = widget.angleResult;
    if (angleResult == null) return const [];
    final activePointNumbers = _activePointerToPoint.values.toSet();

    return widget.points.where((point) => angleResult.editablePointNames.contains(point.name)).map((point) {
      final center = _toCanvasPosition(transform, point);
      const markerExtent = 92.0;

      return Positioned(
        left: center.dx - markerExtent / 2,
        top: center.dy - markerExtent / 2,
        width: markerExtent,
        height: markerExtent,
        child: IgnorePointer(
          child: _PosePointMarker(
            point: point,
            isDragging: activePointNumbers.contains(point.number),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _derivedPointMarkers(ContainedImageTransform transform) {
    final angleResult = widget.angleResult;
    if (angleResult == null) return const [];

    return angleResult.derivedPoints.map((point) {
      final center = transform.toCanvasOffset(point.position);
      const markerExtent = 28.0;

      return Positioned(
        left: center.dx - markerExtent / 2,
        top: center.dy - markerExtent / 2,
        width: markerExtent,
        height: markerExtent,
        child: const IgnorePointer(
          child: _PoseDerivedPointMarker(),
        ),
      );
    }).toList();
  }

  Widget? _angleLabel(ContainedImageTransform transform, AppTheme theme) {
    final angleResult = widget.angleResult;
    if (angleResult == null) return null;

    final vertex = transform.toCanvasOffset(angleResult.vertex.position);

    return Positioned(
      left: vertex.dx + 34,
      top: vertex.dy - 25,
      child: IgnorePointer(
        child: Text(
          '${angleResult.angle.round()}°',
          style: subheadH2Medium.copyWith(color: theme.beige100),
        ),
      ),
    );
  }

  Offset _toCanvasPosition(ContainedImageTransform transform, PoseDataPoint point) {
    return transform.toCanvasOffset(Offset(point.x.toDouble(), point.y.toDouble()));
  }
}

class _PoseLinesPainter extends CustomPainter {
  const _PoseLinesPainter({
    required this.angleResult,
    required this.transform,
    required this.theme,
  });

  final PoseAngleResult? angleResult;
  final ContainedImageTransform transform;
  final AppTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final result = angleResult;
    if (result == null) return;

    final anglePaint = Paint()
      ..color = theme.beige100
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    _drawAngleLines(canvas, result, anglePaint);
  }

  void _drawAngleLines(Canvas canvas, PoseAngleResult result, Paint paint) {
    final vertexPosition = transform.toCanvasOffset(result.vertex.position);
    canvas
      ..drawLine(vertexPosition, transform.toCanvasOffset(result.first.position), paint)
      ..drawLine(vertexPosition, transform.toCanvasOffset(result.second.position), paint);
  }

  @override
  bool shouldRepaint(covariant _PoseLinesPainter oldDelegate) {
    return oldDelegate.angleResult != angleResult || oldDelegate.transform != transform || oldDelegate.theme != theme;
  }
}

class _PosePointMarker extends StatelessWidget {
  const _PosePointMarker({
    required this.point,
    required this.isDragging,
  });

  final PoseDataPoint point;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final markerSize = isDragging ? 38.0 : 34.0;
    final iconSize = isDragging ? 24.0 : 18.0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          top: isDragging ? 2 : 12,
          child: AnimatedOpacity(
            opacity: isDragging ? 1 : 0,
            duration: const Duration(milliseconds: 120),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.beige1000.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.strokeCard),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  point.name.label,
                  style: bodySRegular.copyWith(color: theme.beige100),
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          width: markerSize,
          height: markerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.orange500,
            border: Border.all(
              color: point.isLowConfidence ? theme.orangeButton : theme.beige100.withValues(alpha: 0.35),
              width: point.isLowConfidence ? 2 : 1,
            ),
            boxShadow: [
              if (isDragging)
                BoxShadow(
                  color: theme.orange500.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: iconSize,
              height: iconSize,
              child: SvgPicture.asset(
                point.name.iconAsset,
                colorFilter: ColorFilter.mode(theme.beige100, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PoseDerivedPointMarker extends StatelessWidget {
  const _PoseDerivedPointMarker();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.beige100,
          border: Border.all(color: theme.orange400, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.orange400,
            ),
          ),
        ),
      ),
    );
  }
}
