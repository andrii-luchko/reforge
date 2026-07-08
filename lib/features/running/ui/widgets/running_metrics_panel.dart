import 'package:flutter/material.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/ui/widgets/workout_run_exercise_row.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

class RunningMetricsPanel extends StatelessWidget {
  const RunningMetricsPanel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.speedKmH,
    required this.system,
    this.stepCount,
    super.key,
  });

  factory RunningMetricsPanel.fromExerciseLap(ExerciseLap lap, MeasurementSystem system, {bool isLive = true}) {
    return RunningMetricsPanel(
      distanceMeters: lap.distanceMeters,
      durationSeconds: lap.durationSeconds,
      speedKmH: isLive ? lap.currentSpeedKmH : lap.avgSpeedKmH,
      stepCount: isLive ? lap.stepCount : null,
      system: system,
    );
  }

  final double distanceMeters;
  final int durationSeconds;
  final double speedKmH;
  final MeasurementSystem system;
  final int? stepCount;

  @override
  Widget build(BuildContext context) {
    final km = distanceMeters / 1000;

    return WorkoutRunExerciseRow(
      metrics: WorkoutMetric.runningMetrics,
      system: system,
      durationInSeconds: durationSeconds,
      distanceKm: km,
      pace: speedKmH,
    );
  }
}
