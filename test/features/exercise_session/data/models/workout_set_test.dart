import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  group('WorkoutSet running metrics', () {
    test('converts speed and pace in opposite directions', () {
      final imperial = WorkoutSet(
        id: 1,
        distance: 5,
        speed: 10,
        pace: 6,
      ).toImperial();

      expect(imperial.distance, closeTo(3.106855, 0.000001));
      expect(imperial.speed, closeTo(6.21371, 0.000001));
      expect(imperial.pace, closeTo(9.656064, 0.000001));

      final metric = imperial.toMetric();
      expect(metric.distance, closeTo(5, 0.00001));
      expect(metric.speed, closeTo(10, 0.00001));
      expect(metric.pace, closeTo(6, 0.00001));
    });

    test('includes speed in emptiness and validation', () {
      final set = WorkoutSet(id: 1, speed: 10);

      expect(set.isEmpty, isFalse);
      expect(set.isValid([WorkoutMetric.speed]), isTrue);
      expect(WorkoutSet(id: 2).isValid([WorkoutMetric.speed]), isFalse);
    });
  });
}
