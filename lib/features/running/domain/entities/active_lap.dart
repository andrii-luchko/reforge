import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

/// Snapshot of a running lap that is currently being tracked.
class ActiveLap {
  const ActiveLap({
    required this.driftSetId,
    required this.lapNumber,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceKmH,
    required this.stepCount,
    required this.activity,
  });

  // ignore: comment_references
  /// Row id in [ActiveRunningSets] — used for Drift snapshots.
  final int driftSetId;

  /// 1-based lap index.
  final int lapNumber;

  final double distanceMeters;
  final int durationSeconds;
  final double paceKmH;
  final int stepCount;
  final SegmentActivity activity;

  ActiveLap copyWith({
    int? driftSetId,
    int? lapNumber,
    double? distanceMeters,
    int? durationSeconds,
    double? paceKmH,
    int? stepCount,
    SegmentActivity? activity,
  }) {
    return ActiveLap(
      driftSetId: driftSetId ?? this.driftSetId,
      lapNumber: lapNumber ?? this.lapNumber,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      paceKmH: paceKmH ?? this.paceKmH,
      stepCount: stepCount ?? this.stepCount,
      activity: activity ?? this.activity,
    );
  }
}
