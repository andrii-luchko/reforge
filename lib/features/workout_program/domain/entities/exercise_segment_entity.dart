import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class ExerciseSegmentEntity {
  ExerciseSegmentEntity({
    required this.id,
    required this.order,
    required this.activity,
    required this.targetMetric,
    required this.distanceM,
    required this.durationSec,
    required this.recommendedSpeed,
  });

  final int id;
  final int order;
  final SegmentActivity activity;
  final WorkoutMetric targetMetric;
  final double distanceM;
  final int durationSec;
  final double? recommendedSpeed;

  @override
  String toString() {
    return 'ExerciseSegmentEntity(id: $id, order: $order, activity: $activity, targetMetric: $targetMetric, distanceM: $distanceM, durationSec: $durationSec)';
  }
}
