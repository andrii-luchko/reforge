import 'package:flutter/material.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/entities/active_lap.dart';
import 'package:reforge/features/running/domain/entities/completed_lap.dart';
import 'package:reforge/features/running/ui/widgets/workout_run_exercise_row.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

/// Displays a horizontal row of running metric chips:
/// distance · pace · elapsed time.
///
class RunningMetricsPanel extends StatelessWidget {
  const RunningMetricsPanel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceKmH,
    required this.system,
    this.isLive = false,

    super.key,
  });

  /// Convenience constructor from an [ActiveLap].
  factory RunningMetricsPanel.fromActiveLap(ActiveLap lap, MeasurementSystem system, {bool isLive = true}) {
    return RunningMetricsPanel(
      distanceMeters: lap.distanceMeters,
      durationSeconds: lap.durationSeconds,
      paceKmH: lap.paceKmH,
      system: system,
      isLive: isLive,
    );
  }

  /// Convenience constructor from a [CompletedLap].
  factory RunningMetricsPanel.fromCompletedLap(
    CompletedLap lap,
    MeasurementSystem system,
  ) {
    return RunningMetricsPanel(
      distanceMeters: lap.distanceMeters,
      durationSeconds: lap.durationSeconds,
      paceKmH: lap.paceKmH,
      system: system,
    );
  }

  final double distanceMeters;
  final int durationSeconds;
  final double paceKmH;
  final MeasurementSystem system;

  /// When true, a subtle pulse indicator is shown to signal live updates.
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    //
    final km = distanceMeters / 1000;

    return WorkoutRunExerciseRow(
      metrics: WorkoutMetric.runningMetrics,
      system: system,
      durationInSeconds: durationSeconds,
      distance: km,
      pace: paceKmH,
    );
  }
}
