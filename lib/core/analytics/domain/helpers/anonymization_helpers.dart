/// Pure functions for anonymizing sensitive user data before sending to analytics.
/// Never send PII (email, name, exact weight, birth date) to analytics.
abstract final class AnonymizationHelpers {
  const AnonymizationHelpers._();

  /// Returns a weight bucket string for analytics.
  /// [kg] should be in kilograms (user bodyweight is stored in kg).
  static String weightBucket(double? kg) {
    if (kg == null) return 'unknown';
    if (kg < 50) return 'under_50';
    if (kg < 60) return '50_60';
    if (kg < 70) return '60_70';
    if (kg < 80) return '70_80';
    if (kg < 90) return '80_90';
    return '90_plus';
  }

  /// Returns an age group string for analytics based on birth date.
  static String ageGroup(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    if (age < 18) return 'under_18';
    if (age < 25) return '18_24';
    if (age < 35) return '25_34';
    if (age < 45) return '35_44';
    if (age < 55) return '45_54';
    return '55_plus';
  }
}
