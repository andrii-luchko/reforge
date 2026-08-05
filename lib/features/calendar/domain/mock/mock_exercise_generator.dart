import 'dart:math';

import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class MockExerciseGenerator {
  MockExerciseGenerator._();
  static final _random = Random();

  static List<PreviousExerciseResult> generateList({int count = 5}) {
    return List.generate(count, _generateSingle);
  }

  static PreviousExerciseResult _generateSingle(int index) {
    final exerciseNames = ['Fusion', 'Fusion', 'Fusion', 'Fusion', 'Fusion'];
    final name = exerciseNames[index % exerciseNames.length];

    final metrics = _getMetricsForExercise(name);

    return PreviousExerciseResult(
      name: name,
      description: 'FusionFusionFusion $name — FusionFusionFusionFusionFusionFusionFusion',
      imageUrl: 'https://picsum.photos/200/200?random=$index',
      metrics: metrics,
      notes: _random.nextBool() ? 'FusionFusionFusionFusionFusion' : null,
      sets: _generateSets(metrics),
    );
  }

  static List<WorkoutMetric> _getMetricsForExercise(String name) {
    if (name == 'Fusion') {
      return [WorkoutMetric.distance, WorkoutMetric.time, WorkoutMetric.speed, WorkoutMetric.pace];
    }
    if (name == 'Fusion') return [WorkoutMetric.time];
    return [WorkoutMetric.weight, WorkoutMetric.reps];
  }

  static List<WorkoutSet> _generateSets(List<WorkoutMetric> metrics) {
    return List.generate(3, (i) {
      final speed = metrics.contains(WorkoutMetric.speed) ? (8.5 + _random.nextDouble() % 5) : null;

      return WorkoutSet(
        id: _random.nextInt(10000),
        setNumber: i + 1,
        isDone: true,
        weight: metrics.contains(WorkoutMetric.weight) ? (40.0 + _random.nextInt(60)) : null,
        reps: metrics.contains(WorkoutMetric.reps) ? (8 + _random.nextInt(7)) : null,
        distance: metrics.contains(WorkoutMetric.distance) ? (1000.0 + _random.nextInt(5000)) : null,
        time: metrics.contains(WorkoutMetric.time) ? Duration(seconds: 30 + _random.nextInt(300)) : null,
        speed: speed,
        pace: metrics.contains(WorkoutMetric.pace) && speed != null ? 60 / speed : null,
      );
    });
  }
}
