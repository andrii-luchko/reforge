import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

void main() {
  group('WorkoutConstants', () {
    group('maxWeight', () {
      test('returns 600 for metric', () {
        expect(WorkoutConstants.maxWeight(MeasurementSystem.metric), 600);
      });

      test('returns 1325 for imperial', () {
        expect(WorkoutConstants.maxWeight(MeasurementSystem.imperial), 1325);
      });
    });

    group('weightStep', () {
      test('returns 0.5 for metric', () {
        expect(WorkoutConstants.weightStep(MeasurementSystem.metric), 0.5);
      });

      test('returns 1 for imperial', () {
        expect(WorkoutConstants.weightStep(MeasurementSystem.imperial), 1);
      });
    });

    group('maxDistance', () {
      test('returns 200 for metric', () {
        expect(WorkoutConstants.maxDistance(MeasurementSystem.metric), 200);
      });

      test('returns 125 for imperial', () {
        expect(WorkoutConstants.maxDistance(MeasurementSystem.imperial), 125);
      });
    });

    group('maxSpeed', () {
      test('returns 50 for metric', () {
        expect(WorkoutConstants.maxSpeed(MeasurementSystem.metric), 50);
      });

      test('returns 30 for imperial', () {
        expect(WorkoutConstants.maxSpeed(MeasurementSystem.imperial), 30);
      });
    });

    group('constants', () {
      test('minWeight is 0', () {
        expect(WorkoutConstants.minWeight, 0);
      });

      test('minDistance is 0', () {
        expect(WorkoutConstants.minDistance, 0);
      });

      test('distanceStep is 0.1', () {
        expect(WorkoutConstants.distanceStep, 0.1);
      });

      test('minSpeed is 0', () {
        expect(WorkoutConstants.minSpeed, 0);
      });

      test('speedStep is 0.1', () {
        expect(WorkoutConstants.speedStep, 0.1);
      });

      test('minReps is 0', () {
        expect(WorkoutConstants.minReps, 0);
      });

      test('maxReps is 500', () {
        expect(WorkoutConstants.maxReps, 500);
      });

      test('repsStep is 1', () {
        expect(WorkoutConstants.repsStep, 1);
      });

      test('minDegree is 0', () {
        expect(WorkoutConstants.minDegree, 0);
      });

      test('maxDegree is 360', () {
        expect(WorkoutConstants.maxDegree, 360);
      });

      test('degreeStep is 1', () {
        expect(WorkoutConstants.degreeStep, 1);
      });
    });
  });
}
