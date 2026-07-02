import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/entities/completed_lap.dart';
import 'package:reforge/features/running/ui/widgets/workout_run_exercise_row.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/shared/uikit/app_tag.dart';

/// Compact scrollable list of completed laps.
///
/// Shows a row per lap with lap number, distance, pace and time.
class RunningLapsList extends StatelessWidget {
  const RunningLapsList({
    required this.metrics,
    required this.system,
    required this.laps,
    super.key,
  });

  final List<WorkoutMetric> metrics;

  final MeasurementSystem system;
  final List<CompletedLap> laps;

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        ...laps.map(
          (lap) => _LapRow(
            lap: lap,
            metrics: metrics,
            system: system,
          ),
        ),
      ],
    );
  }
}

class _LapRow extends StatelessWidget {
  const _LapRow({
    required this.metrics,
    required this.system,
    required this.lap,
  });

  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;
  final CompletedLap lap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    //TODO(Masayoshi): translate base on current measure system;
    final km = lap.distanceMeters / 1000;

    return Column(
      children: [
        Padding(
          padding: const .only(bottom: 16),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Lap ${lap.lapNumber}',

                style: subheadH2Medium.copyWith(color: appTheme.beige100),
              ),
              AppTag(text: lap.activity.title),
            ],
          ),
        ),

        Container(
          padding: const .all(16),
          decoration: BoxDecoration(
            borderRadius: .circular(16),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                stops: const [0.3, 0.9, 1],
                colors: [
                  appTheme.strokeCalendar,
                  appTheme.strokeCalendar.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          child: WorkoutRunExerciseRow(
            distance: km,
            durationInSeconds: lap.durationSeconds,
            pace: lap.paceKmH,
            metrics: metrics,
            system: system,
          ),
        ),
      ],
    );
  }
}
