import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/domain/services/treadmill_speed_validation.dart';

void main() {
  test('accepts only finite positive canonical speeds', () {
    for (final speedKmH in <double>[0.1, 5, 25]) {
      expect(TreadmillSpeedValidation.isValid(speedKmH), isTrue);
      expect(() => TreadmillSpeedValidation.validate(speedKmH), returnsNormally);
    }

    for (final speedKmH in <double>[
      0,
      -1,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(TreadmillSpeedValidation.isValid(speedKmH), isFalse);
      expect(
        () => TreadmillSpeedValidation.validate(speedKmH),
        throwsArgumentError,
      );
    }

    expect(TreadmillSpeedValidation.isValid(null), isFalse);
  });
}
