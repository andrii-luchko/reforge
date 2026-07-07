import 'package:flutter/material.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/timer/ui/smooth_timer_text.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutRunExerciseRow extends StatelessWidget {
  const WorkoutRunExerciseRow({
    required this.metrics,
    required this.system,
    required this.durationInSeconds,
    required this.distanceKm,
    required this.pace,
    super.key,
  });

  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;

  final int durationInSeconds;
  final double distanceKm;
  final double pace;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final style = subheadH3Medium.copyWith(color: appTheme.beige100);

    final m = (durationInSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (durationInSeconds % 60).toString().padLeft(2, '0');
    final time = '$m:$s';

    var displayDistance = distanceKm;
    var displayPace = pace;

    if (system == MeasurementSystem.imperial) {
      displayDistance = MeasureSystemValues.toMiles(displayDistance);
      displayPace = MeasureSystemValues.toMiles(displayPace);
    }

    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 7,
          children: metrics.map((m) {
            return Expanded(
              child: Text(
                m.title(t, system),
                style: style,
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),

        Row(
          spacing: 7,
          children: [
            Expanded(
              child: _WorkoutContainer(
                child: Center(
                  child: SmoothTimerText(time, style: style),
                ),
              ),
            ),
            Expanded(
              child: _WorkoutContainer(child: Center(child: FadedMetricText(displayDistance.toStringAsFixed(2)))),
            ),
            Expanded(
              child: _WorkoutContainer(child: Center(child: FadedMetricText(displayPace.toStringAsFixed(1)))),
            ),
          ],
        ),
      ],
    );
  }
}

class FadedMetricText extends StatelessWidget {
  const FadedMetricText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: subheadH3Medium.copyWith(
          color: appTheme.beige100,
          fontFeatures: [],
        ),
      ),
    );
  }
}

class _WorkoutContainer extends StatelessWidget {
  const _WorkoutContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const .symmetric(vertical: 21, horizontal: 28),
      decoration: BoxDecoration(
        borderRadius: appTheme.workoutContainerBorderRadius,
        color: appTheme.beige900,
      ),
      child: child,
    );
  }
}
