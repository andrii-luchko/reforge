// ignore_for_file: comment_references

import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';

/// Abstract interface for real-time running tracking.
///
/// Two implementations exist:
/// - [PedometerTrackingService] — uses the device step counter (treadmill mode).
/// - [GpsTrackingService] — uses GPS position stream (outdoor mode).
abstract interface class RunningTrackingService {
  /// Stream of live [RunningMetrics] for the current lap.
  ///
  /// Emits a new value every time the underlying sensor produces data
  /// (approximately once per second for pedometer, once per position fix
  /// for GPS). The stream is empty (no events) when tracking is stopped.
  Stream<RunningMetrics> get metricsStream;

  /// The tracking mode currently in use. Null when not tracking.
  RunningMode? get currentMode;

  /// Starts tracking with the given [mode] and [segments] playlist.
  ///
  /// Must be called before [metricsStream] emits any values.
  /// Calling while already tracking is a no-op.
  Future<void> startTracking({
    required RunningMode mode,
    required List<LapLimit> limits,
    RunningMetrics? initialOffset,
    int? workoutSessionId,
    int? programExerciseId,
  });

  /// Pauses metric emission without releasing sensors.
  ///
  /// The [metricsStream] stops emitting but the pedometer / GPS listener
  /// remains active so that accumulated steps / distance are preserved.
  void pauseTracking();

  /// Resumes tracking (e.g. returning from pause).
  void resumeTracking();

  /// Forces the current lap to finish immediately, taking a snapshot and starting the next one.
  void forceNextLap();

  /// Stops tracking permanently and cleans up resources.
  ///
  /// After this call [metricsStream] completes and [currentMode] is null.
  /// Call [startTracking] to begin a new lap.
  void stopTracking();

  /// Resets accumulated metrics (distance, steps, duration) to zero.
  ///
  /// Call between laps so each lap starts from a clean baseline.
  void resetMetrics();
}
