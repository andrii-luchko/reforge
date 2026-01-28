import 'package:flutter/material.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/training_session/data/models/workout_set.dart';
import 'package:reforge/features/training_session/domain/enums/workout_metrics.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_container.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_dialogs.dart';
import 'package:reforge/features/training_session/ui/widgets/uikit/workout_done_button.dart';
import 'package:reforge/features/training_session/ui/widgets/uikit/workout_field.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_row_layout.dart';

class WorkoutExerciseRow extends StatelessWidget {
  const WorkoutExerciseRow({
    required this.setNumber,
    required this.metrics,
    required this.set,
    required this.onMetricChanged,
    required this.onDonePressed,
    required this.system,
    super.key,
  });
  final int setNumber;
  final List<WorkoutMetric> metrics;
  final WorkoutSet set;
  final ValueChanged<WorkoutSet> onMetricChanged;
  final VoidCallback onDonePressed;
  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    final isDone = set.isDone;

    return WorkoutRowLayout(
      setsCell: WorkoutContainer(
        text: setNumber.toString(),
      ),

      metricCells: metrics.map((metric) {
        final value = set.getValue(metric);
        if (metric == WorkoutMetric.reps) {
          return WorkoutField(
            metric: metric,
            isDone: isDone,

            hintText: '-',
            initialValue: value?.toString(),
            onChanged: (value) {
              final newValue = value.isEmpty ? null : int.tryParse(value);

              if (newValue != null || value.isEmpty) {
                final updatedSet = set.copyWithMetric(metric, newValue ?? 0);
                onMetricChanged(updatedSet);
              }
            },
          );
        }

        if (metric == WorkoutMetric.weight) {
          return WorkoutField(
            metric: metric,
            isDone: isDone,
            hintText: '-',
            initialValue: value?.toString(),
            onChanged: (value) {
              final newValue = value.isEmpty ? null : double.tryParse(value);

              if (newValue != null || value.isEmpty) {
                final updatedSet = set.copyWithMetric(metric, newValue ?? 0);
                onMetricChanged(updatedSet);
              }
            },
          );
        }

        return WorkoutContainer(
          text: set.formatValue(metric: metric),
          onTap: set.isDone ? null : () => _handleTap(context, metric, value),
        );
      }).toList(),

      doneCell: WorkoutDoneButton.icon(
        isDone: isDone,
        onTap: isDone ? null : onDonePressed,
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WorkoutMetric metric, dynamic currentValue) async {
    final newValue = await WorkoutDialogs.showAppropriateDialog(context, metric, currentValue, system);

    if (newValue != null) {
      final updatedSet = set.copyWithMetric(metric, newValue);
      onMetricChanged(updatedSet);
    }
  }
}
