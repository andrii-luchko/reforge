import 'package:flutter/material.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/timer/ui/smooth_timer_text.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutRunExerciseRow extends StatelessWidget {
  const WorkoutRunExerciseRow({
    required this.metrics,
    required this.system,
    required this.durationInSeconds,
    required this.distanceKm,
    required this.speedKmH,
    required this.paceMinKm,
    this.isOverview = false,
    super.key,
  });

  static const _sectionSpacing = 16.0;
  static const _metricSpacing = 7.0;

  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;

  final int durationInSeconds;
  final double distanceKm;
  final double speedKmH;
  final double paceMinKm;
  final bool isOverview;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textStyle = subheadH3Medium.copyWith(
      color: appTheme.beige100,
    );

    final isImperial = system == MeasurementSystem.imperial;

    final displayDistance = isImperial ? MeasureSystemValues.toMiles(distanceKm) : distanceKm;

    final displaySpeed = isImperial ? MeasureSystemValues.toMiles(speedKmH) : speedKmH;

    // ignore: unused_local_variable
    final displayPace = isImperial ? MeasureSystemValues.toMiles(paceMinKm) : paceMinKm;

    final metricValues = <Widget>[
      _buildDurationValue(textStyle),
      _buildMetricValue(
        displayDistance.toStringAsFixed(2),
        textStyle,
      ),
      _buildMetricValue(
        displaySpeed.toStringAsFixed(1),
        textStyle,
      ),
      //      _buildMetricValue(
      //   displayPace.toStringAsFixed(1),
      //   textStyle,
      // ),
    ];

    return Column(
      spacing: _sectionSpacing,
      children: [
        _EqualWidthRow(
          spacing: _metricSpacing,
          children: [
            for (final metric in metrics)
              Text(
                metric.title(t, system),
                style: textStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
          ],
        ),
        _EqualWidthRow(
          spacing: _metricSpacing,
          children: [
            for (final value in metricValues)
              _WorkoutContainer(
                child: Center(child: value),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationValue(TextStyle style) {
    final minutes = (durationInSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');

    final formattedDuration = '$minutes:$seconds';

    return SmoothTimerText(
      formattedDuration,
      style: style,
    );
  }

  Widget _buildMetricValue(
    String value,
    TextStyle style,
  ) {
    if (isOverview) {
      return Text(
        value,
        style: style,
        maxLines: 1,
      );
    }

    return FadedMetricText(
      value,
      style: style,
    );
  }
}

class _EqualWidthRow extends StatelessWidget {
  const _EqualWidthRow({
    required this.children,
    required this.spacing,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing,
      children: [
        for (final child in children) Expanded(child: child),
      ],
    );
  }
}

class FadedMetricText extends StatelessWidget {
  const FadedMetricText(
    this.text, {
    required this.style,
    super.key,
  });

  static const _animationDuration = Duration(milliseconds: 100);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        maxLines: 1,
        style: style.copyWith(
          fontFeatures: const [],
        ),
      ),
    );
  }
}

class _WorkoutContainer extends StatelessWidget {
  const _WorkoutContainer({
    required this.child,
  });

  static const EdgeInsets padding = EdgeInsets.symmetric(
    vertical: 21,
    horizontal: 28,
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: appTheme.workoutContainerBorderRadius,
        color: appTheme.beige900,
      ),
      child: child,
    );
  }
}
