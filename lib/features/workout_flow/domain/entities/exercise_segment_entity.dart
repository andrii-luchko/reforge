import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

class ExerciseSegmentEntity {
  ExerciseSegmentEntity({
    required this.id,
    required this.order,
    required this.activity,
    required this.targetMetric,
    required this.distanceM,
    required this.durationSec,
  });

  final int id;
  final int order;
  final SegmentActivity activity;
  final WorkoutMetric targetMetric;
  final int distanceM;
  final int durationSec;

  @override
  String toString() {
    return 'ExerciseSegmentEntity(id: $id, order: $order, activity: $activity, targetMetric: $targetMetric, distanceM: $distanceM, durationSec: $durationSec)';
  }
}
