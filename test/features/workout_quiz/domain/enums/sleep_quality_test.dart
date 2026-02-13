import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/workout_quiz/domain/enums/sleep_quality.dart';

void main() {
  group('SleepQualityExtension.score', () {
    test('veryPoor returns 1', () {
      expect(SleepQuality.veryPoor.score, 1);
    });

    test('poor returns 2', () {
      expect(SleepQuality.poor.score, 2);
    });

    test('average returns 3', () {
      expect(SleepQuality.average.score, 3);
    });

    test('good returns 4', () {
      expect(SleepQuality.good.score, 4);
    });

    test('excellent returns 5', () {
      expect(SleepQuality.excellent.score, 5);
    });
  });
}
