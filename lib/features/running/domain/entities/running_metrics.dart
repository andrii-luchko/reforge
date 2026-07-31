import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';

/// A snapshot of real-time running metrics emitted by [TrackingEngine].
///
/// Immutable — each event from the tracking stream produces a new instance.
class RunningMetrics {
  const RunningMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgSpeedKmH,
    required this.currentSpeedKmH,
    required this.avgPaceMinKm,
    required this.currentPaceMinKm,
    required this.stepCount,
    this.currentLocation,
    this.currentSegment,
    this.currentSegmentIndex = 0,
    this.segmentId,
    this.activityType = SegmentActivity.run,
  });

  const RunningMetrics.zero()
    : distanceMeters = 0,
      durationSeconds = 0,
      avgSpeedKmH = 0,
      currentSpeedKmH = 0,
      avgPaceMinKm = 0,
      currentPaceMinKm = 0,
      stepCount = 0,
      currentLocation = null,
      currentSegment = null,
      currentSegmentIndex = 0,
      segmentId = null,
      activityType = SegmentActivity.run;

  /// Total distance covered in this lap, in metres.
  final double distanceMeters;

  /// Elapsed time for this lap, in seconds.
  final int durationSeconds;

  /// Average speed in km/h. Derived from total distance and duration.
  final double avgSpeedKmH;

  /// Current instantaneous speed in km/h.
  final double currentSpeedKmH;

  /// Average pace in minutes per kilometer.
  final double avgPaceMinKm;

  /// Current instantaneous pace in minutes per kilometer.
  final double currentPaceMinKm;

  /// Raw step count from the pedometer (0 when in GPS mode).
  final int stepCount;

  /// Latest GPS coordinate, if available.
  final RouteCoordinate? currentLocation;

  /// The currently active segment from the playlist.
  final ExerciseSegmentEntity? currentSegment;

  /// Index of the current segment in the playlist.
  final int currentSegmentIndex;

  /// The backend ID of the current segment (if applicable).
  final int? segmentId;

  /// The activity type of the current segment.
  final SegmentActivity activityType;

  RunningMetrics copyWith({
    double? distanceMeters,
    int? durationSeconds,
    double? avgSpeedKmH,
    double? currentSpeedKmH,
    double? avgPaceMinKm,
    double? currentPaceMinKm,
    int? stepCount,
    RouteCoordinate? currentLocation,
    ExerciseSegmentEntity? currentSegment,
    int? currentSegmentIndex,
    int? segmentId,
    SegmentActivity? activityType,
  }) {
    return RunningMetrics(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgSpeedKmH: avgSpeedKmH ?? this.avgSpeedKmH,
      currentSpeedKmH: currentSpeedKmH ?? this.currentSpeedKmH,
      avgPaceMinKm: avgPaceMinKm ?? this.avgPaceMinKm,
      currentPaceMinKm: currentPaceMinKm ?? this.currentPaceMinKm,
      stepCount: stepCount ?? this.stepCount,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSegment: currentSegment ?? this.currentSegment,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      segmentId: segmentId ?? this.segmentId,
      activityType: activityType ?? this.activityType,
    );
  }

  @override
  String toString() =>
      'RunningMetrics(dist: ${distanceMeters.toStringAsFixed(1)} m, '
      'dur: ${durationSeconds}s, avgSpeed: ${avgSpeedKmH.toStringAsFixed(2)} km/h, '
      'curSpeed: ${currentSpeedKmH.toStringAsFixed(2)} km/h, steps: $stepCount)';
}
