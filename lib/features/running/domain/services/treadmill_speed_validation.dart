/// Shared validation policy for manually configured treadmill speed.
abstract final class TreadmillSpeedValidation {
  /// A treadmill lap requires a finite, positive canonical speed.
  static bool isValid(double? speedKmH) {
    return speedKmH != null && speedKmH.isFinite && speedKmH > 0;
  }

  /// Throws when [speedKmH] cannot be used by manual treadmill tracking.
  static void validate(double speedKmH) {
    if (!isValid(speedKmH)) {
      throw ArgumentError.value(
        speedKmH,
        'speedKmH',
        'Treadmill speed must be finite and greater than zero.',
      );
    }
  }
}
