import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/training_session/domain/enums/workout_metrics.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_row_layout.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class ResultExerciseHeader extends StatelessWidget {
  const ResultExerciseHeader({
    required this.metrics,
    required this.system,
    super.key,
  });

  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    final style = subheadH3Medium.copyWith(color: context.appTheme.beige100);

    return WorkoutRowLayout(
      setsCell: Text('Sets', style: style, textAlign: TextAlign.center),

      metricCells: metrics.map((m) {
        return Text(
          m.title(t, system),
          style: style,
          textAlign: TextAlign.center,
        );
      }).toList(),

      doneCell: null,
    );
  }
}
