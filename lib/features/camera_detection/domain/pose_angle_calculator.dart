import 'dart:math' as math;

import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';

class PoseAngleCalculator {
  const PoseAngleCalculator();

  static const firstPointName = 'left_shoulder';
  static const vertexPointName = 'left_pelvis';
  static const secondPointName = 'left_knee';

  double calculate(List<PoseDataPoint> points) {
    final first = _findPoint(points, firstPointName);
    final vertex = _findPoint(points, vertexPointName);
    final second = _findPoint(points, secondPointName);

    if (first == null || vertex == null || second == null) return 0;

    final vectorA = (x: first.x - vertex.x, y: first.y - vertex.y);
    final vectorB = (x: second.x - vertex.x, y: second.y - vertex.y);
    final dot = vectorA.x * vectorB.x + vectorA.y * vectorB.y;
    final lengthA = math.sqrt(vectorA.x * vectorA.x + vectorA.y * vectorA.y);
    final lengthB = math.sqrt(vectorB.x * vectorB.x + vectorB.y * vectorB.y);

    if (lengthA == 0 || lengthB == 0) return 0;

    final cosine = (dot / (lengthA * lengthB)).clamp(-1.0, 1.0);
    final radians = math.acos(cosine);

    return radians * 180 / math.pi;
  }

  bool isAnglePoint(PoseDataPoint point) {
    return point.name == firstPointName || point.name == vertexPointName || point.name == secondPointName;
  }

  PoseDataPoint? _findPoint(List<PoseDataPoint> points, String name) {
    for (final point in points) {
      if (point.name == name) return point;
    }

    return null;
  }
}
