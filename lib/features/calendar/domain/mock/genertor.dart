import 'dart:math';

import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';

class MockExerciseGenerator {
  MockExerciseGenerator._();
  static final _random = Random();

  static List<PreviousExerciseResult> generateList({int count = 5}) {
    return List.generate(count, (index) => _generateSingle(index));
  }

  static PreviousExerciseResult _generateSingle(int index) {
    final exerciseNames = ['Приседания', 'Жим лежа', 'Становая тяга', 'Бег', 'Планка'];
    final name = exerciseNames[index % exerciseNames.length];

    final metrics = _getMetricsForExercise(name);

    return PreviousExerciseResult(
      name: name,
      description: 'Описание для $name — отличная тренировка на все группы мышц.',
      imageUrl: 'https://picsum.photos/200/200?random=$index',
      metrics: metrics,
      notes: _random.nextBool() ? 'Чувствовал себя отлично, увеличил вес' : null,
      sets: _generateSets(metrics),
    );
  }

  static List<WorkoutMetric> _getMetricsForExercise(String name) {
    if (name == 'Бег') return [WorkoutMetric.distance, WorkoutMetric.time, WorkoutMetric.pace];
    if (name == 'Планка') return [WorkoutMetric.time];
    return [WorkoutMetric.weight, WorkoutMetric.reps];
  }

  static List<WorkoutSet> _generateSets(List<WorkoutMetric> metrics) {
    return List.generate(3, (i) {
      return WorkoutSet(
        id: _random.nextInt(10000),
        setNumber: i + 1,
        isDone: true,
        // Заполняем только те поля, которые есть в метриках
        weight: metrics.contains(WorkoutMetric.weight) ? (40.0 + _random.nextInt(60)) : null,
        reps: metrics.contains(WorkoutMetric.reps) ? (8 + _random.nextInt(7)) : null,
        distance: metrics.contains(WorkoutMetric.distance) ? (1000.0 + _random.nextInt(5000)) : null,
        time: metrics.contains(WorkoutMetric.time) ? Duration(seconds: 30 + _random.nextInt(300)) : null,
        pace: metrics.contains(WorkoutMetric.pace) ? (8.5 + _random.nextDouble() % 5) : null,
      );
    });
  }
}
