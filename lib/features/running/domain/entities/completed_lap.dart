import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

/// A lap that has been completed and persisted to the backend.
class CompletedLap {
  const CompletedLap({
    required this.lapNumber,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceKmH,
    required this.activity,
  });

  final int lapNumber;
  final double distanceMeters;
  final int durationSeconds;
  final double paceKmH;
  final SegmentActivity activity;
}
