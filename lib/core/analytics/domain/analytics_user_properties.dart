/// Constants for analytics user property names.
/// Only use anonymized values - no PII (email, name, exact weight, etc.).
abstract final class AnalyticsUserProperties {
  const AnalyticsUserProperties._();

  static const String measurementSystem = 'measurement_system';
  static const String factionId = 'faction_id';
  static const String workoutsPerWeek = 'workouts_per_week';
  static const String ageGroup = 'age_group';
  static const String weightRange = 'weight_range';
  static const String subscriptionStatus = 'subscription_status';
}
