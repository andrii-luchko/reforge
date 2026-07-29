import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart' as domain;

void main() {
  group('MeasureSystemValues', () {
    group('Distance conversions', () {
      test('toMiles and toKm round-trip', () {
        const km = 10.0;
        final miles = MeasureSystemValues.toMiles(km);
        final backToKm = MeasureSystemValues.toKm(miles);
        expect(backToKm, closeTo(km, 0.001));
      });

      test('toFeet and toMeters round-trip', () {
        const meters = 10.0;
        final feet = MeasureSystemValues.toFeet(meters);
        final backToMeters = MeasureSystemValues.toMeters(feet);
        expect(backToMeters, closeTo(meters, 0.001));
      });

      test('toInches and toCm round-trip', () {
        const cm = 100.0;
        final inches = MeasureSystemValues.toInches(cm);
        final backToCm = MeasureSystemValues.toCm(inches);
        expect(backToCm, closeTo(cm, 0.001));
      });
    });

    group('Weight conversions', () {
      test('toPounds and toKg round-trip', () {
        const kg = 70.0;
        final lbs = MeasureSystemValues.toPounds(kg);
        final backToKg = MeasureSystemValues.toKg(lbs);
        expect(backToKg, closeTo(kg, 0.001));
      });

      test('toOunces and toGrams round-trip', () {
        const grams = 100.0;
        final ounces = MeasureSystemValues.toOunces(grams);
        final backToGrams = MeasureSystemValues.toGrams(ounces);
        expect(backToGrams, closeTo(grams, 0.01));
      });
    });

    group('Geometry conversions', () {
      test('toRadians and toDegrees round-trip', () {
        const degrees = 180.0;
        final radians = MeasureSystemValues.toRadians(degrees);
        final backToDegrees = MeasureSystemValues.toDegrees(radians);
        expect(backToDegrees, closeTo(degrees, 0.0001));
      });

      test('90 degrees equals pi/2 radians', () {
        final radians = MeasureSystemValues.toRadians(90);
        expect(radians, closeTo(1.5708, 0.0001));
      });
    });
  });

  group('WeightConverter', () {
    test('toDisplayWeight returns same value for metric', () {
      expect(70.0.toDisplayWeight(domain.MeasurementSystem.metric), 70.0);
    });

    test('toDisplayWeight converts to pounds for imperial', () {
      final result = 1.0.toDisplayWeight(domain.MeasurementSystem.imperial);
      expect(result, closeTo(2.20462, 0.001));
    });

    test('toStorageWeight returns same value for metric', () {
      expect(70.0.toStorageWeight(domain.MeasurementSystem.metric), 70.0);
    });

    test('toStorageWeight converts to kg for imperial', () {
      final result = 2.20462.toStorageWeight(domain.MeasurementSystem.imperial);
      expect(result, closeTo(1.0, 0.001));
    });

    test('roundWeight rounds to two decimal places', () {
      expect(70.555.roundWeight(), 70.56);
    });

    test('formatWeight removes trailing zeroes', () {
      expect(70.0.formatWeight(), '70');
      expect(70.5.formatWeight(), '70.5');
      expect(70.555.formatWeight(), '70.56');
    });
  });

  group('DistanceConverter', () {
    test('toDisplayHeight returns same value for metric', () {
      expect(170.0.toDisplayHeight(domain.MeasurementSystem.metric), 170.0);
    });

    test('toDisplayHeight converts to inches for imperial', () {
      final result = 2.54.toDisplayHeight(domain.MeasurementSystem.imperial);
      expect(result, closeTo(1.0, 0.01));
    });
  });
}
