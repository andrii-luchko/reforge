import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_point_name.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@immutable
class PoseAngleResult {
  const PoseAngleResult({
    required this.angle,
    required this.first,
    required this.vertex,
    required this.second,
    required this.editablePointNames,
    required this.derivedPoints,
  });

  final double angle;
  final PosePoint2D first;
  final PosePoint2D vertex;
  final PosePoint2D second;
  final Set<PosePointName> editablePointNames;
  final List<PoseDerivedPoint> derivedPoints;
}

@immutable
class PosePoint2D {
  const PosePoint2D({
    required this.position,
    this.score,
  });

  final Offset position;
  final double? score;

  bool get isLowConfidence => score != null && score! < 0.7;
}

@immutable
class PoseDerivedPoint extends PosePoint2D {
  const PoseDerivedPoint({
    required super.position,
    required this.label,
    super.score,
  });

  final String label;
}

class PoseAngleCalculator {
  const PoseAngleCalculator();

  PoseAngleResult? calculate({
    required PoseDetectionPreset preset,
    required List<PoseDataPoint> points,
  }) {
    return switch (preset) {
      PoseDetectionPreset.legs => _calculateLegs(points),
      PoseDetectionPreset.spine => _calculateSpine(points),
    };
  }

  PoseAngleResult? _calculateLegs(List<PoseDataPoint> points) {
    final leftPelvis = _findPoint(points, PosePointName.leftPelvis);
    final rightPelvis = _findPoint(points, PosePointName.rightPelvis);
    final leftFoot = _findPoint(points, PosePointName.leftFoot);
    final rightFoot = _findPoint(points, PosePointName.rightFoot);

    if (leftPelvis == null || rightPelvis == null || leftFoot == null || rightFoot == null) return null;

    final pelvisCenter = _midpoint(leftPelvis, rightPelvis, t.camera_detection.posePoints.pelvisCenter);
    final first = _fromPoint(leftFoot);
    final second = _fromPoint(rightFoot);

    return PoseAngleResult(
      angle: _angle(first.position, pelvisCenter.position, second.position),
      first: first,
      vertex: pelvisCenter,
      second: second,
      editablePointNames: const {
        PosePointName.leftPelvis,
        PosePointName.rightPelvis,
        PosePointName.leftFoot,
        PosePointName.rightFoot,
      },
      derivedPoints: [pelvisCenter],
    );
  }

  PoseAngleResult? _calculateSpine(List<PoseDataPoint> points) {
    final leftShoulder = _findPoint(points, PosePointName.leftShoulder);
    final rightShoulder = _findPoint(points, PosePointName.rightShoulder);
    final leftPelvis = _findPoint(points, PosePointName.leftPelvis);
    final rightPelvis = _findPoint(points, PosePointName.rightPelvis);
    final leftKnee = _findPoint(points, PosePointName.leftKnee);
    final rightKnee = _findPoint(points, PosePointName.rightKnee);

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftPelvis == null ||
        rightPelvis == null ||
        leftKnee == null ||
        rightKnee == null) {
      return null;
    }

    final shoulderCenter = _midpoint(leftShoulder, rightShoulder, t.camera_detection.posePoints.shoulderCenter);
    final pelvisCenter = _midpoint(leftPelvis, rightPelvis, t.camera_detection.posePoints.pelvisCenter);
    final kneeCenter = _midpoint(leftKnee, rightKnee, t.camera_detection.posePoints.kneeCenter);

    return PoseAngleResult(
      angle: _angle(shoulderCenter.position, pelvisCenter.position, kneeCenter.position),
      first: shoulderCenter,
      vertex: pelvisCenter,
      second: kneeCenter,
      editablePointNames: const {
        PosePointName.leftShoulder,
        PosePointName.rightShoulder,
        PosePointName.leftPelvis,
        PosePointName.rightPelvis,
        PosePointName.leftKnee,
        PosePointName.rightKnee,
      },
      derivedPoints: [shoulderCenter, pelvisCenter, kneeCenter],
    );
  }

  PoseDataPoint? _findPoint(List<PoseDataPoint> points, PosePointName name) {
    for (final point in points) {
      if (point.name == name) return point;
    }

    return null;
  }

  PosePoint2D _fromPoint(PoseDataPoint point) {
    return PosePoint2D(
      position: Offset(point.x.toDouble(), point.y.toDouble()),
      score: point.score,
    );
  }

  PoseDerivedPoint _midpoint(PoseDataPoint first, PoseDataPoint second, String label) {
    return PoseDerivedPoint(
      label: label,
      position: Offset(
        (first.x + second.x) / 2,
        (first.y + second.y) / 2,
      ),
      score: math.min(first.score, second.score),
    );
  }

  double _angle(Offset first, Offset vertex, Offset second) {
    final vectorA = first - vertex;
    final vectorB = second - vertex;
    final dot = vectorA.dx * vectorB.dx + vectorA.dy * vectorB.dy;
    final lengthA = vectorA.distance;
    final lengthB = vectorB.distance;

    if (lengthA == 0 || lengthB == 0) return 0;

    final cosine = (dot / (lengthA * lengthB)).clamp(-1.0, 1.0);
    final radians = math.acos(cosine);

    return radians * 180 / math.pi;
  }
}
