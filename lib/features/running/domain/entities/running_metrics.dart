import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_segment_entity.dart';

/// A snapshot of real-time running metrics emitted by [TrackingEngine].
///
/// Immutable — each event from the tracking stream produces a new instance.
class RunningMetrics {
  const RunningMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceKmH,
    required this.stepCount,
    this.currentLocation,
    this.currentSegment,
    this.currentSegmentIndex = 0,
  });

  const RunningMetrics.zero()
    : distanceMeters = 0,
      durationSeconds = 0,
      paceKmH = 0,
      stepCount = 0,
      currentLocation = null,
      currentSegment = null,
      currentSegmentIndex = 0;

  /// Total distance covered in this lap, in metres.
  final double distanceMeters;

  /// Elapsed time for this lap, in seconds.
  final int durationSeconds;

  /// Current pace in km/h. Derived from distance and duration.
  final double paceKmH;

  /// Raw step count from the pedometer (0 when in GPS mode).
  final int stepCount;

  /// Latest GPS coordinate, if available.
  final RouteCoordinate? currentLocation;

  /// The currently active segment from the playlist.
  final ExerciseSegmentEntity? currentSegment;

  /// Index of the current segment in the playlist.
  final int currentSegmentIndex;

  RunningMetrics copyWith({
    double? distanceMeters,
    int? durationSeconds,
    double? paceKmH,
    int? stepCount,
    RouteCoordinate? currentLocation,
    ExerciseSegmentEntity? currentSegment,
    int? currentSegmentIndex,
  }) {
    return RunningMetrics(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      paceKmH: paceKmH ?? this.paceKmH,
      stepCount: stepCount ?? this.stepCount,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSegment: currentSegment ?? this.currentSegment,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
    );
  }

  @override
  String toString() =>
      'RunningMetrics(dist: ${distanceMeters.toStringAsFixed(1)} m, '
      'dur: ${durationSeconds}s, pace: ${paceKmH.toStringAsFixed(2)} km/h, '
      'steps: $stepCount)';
}
