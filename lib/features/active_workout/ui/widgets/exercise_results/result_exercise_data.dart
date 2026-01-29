import 'package:flutter/widgets.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart'; //
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_container.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_row_layout.dart';

class ResultExerciseData extends StatelessWidget {
  const ResultExerciseData({
    required this.metrics,
    required this.set,
    required this.setNumber,
    required this.system,
    super.key,
  });

  final List<WorkoutMetric> metrics;
  final WorkoutSet set;
  final int setNumber;
  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    return WorkoutRowLayout(
      setsCell: WorkoutContainer(
        text: setNumber.toString(),
      ),

      metricCells: metrics.map((metric) {
        return WorkoutContainer(
          text: set.formatValue(metric: metric),
        );
      }).toList(),

      doneCell: null,
    );
  }
}
