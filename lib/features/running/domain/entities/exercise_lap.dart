import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

/// A universal model for both active and completed running laps.
class ExerciseLap {
  const ExerciseLap({
    required this.lapNumber,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceKmH,
    this.driftSetId,
    this.stepCount = 0,
    this.activity = SegmentActivity.run,
  });

  // ignore: comment_references
  /// Row id in [ActiveRunningSets] — used for Drift snapshots while active.
  /// Null if this lap was loaded from the backend (historical).
  final int? driftSetId;

  /// 1-based lap index.
  final int lapNumber;

  final double distanceMeters;
  final int durationSeconds;
  final double paceKmH;
  final int stepCount;
  final SegmentActivity activity;

  ExerciseLap copyWith({
    int? driftSetId,
    int? lapNumber,
    double? distanceMeters,
    int? durationSeconds,
    double? paceKmH,
    int? stepCount,
    SegmentActivity? activity,
  }) {
    return ExerciseLap(
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
