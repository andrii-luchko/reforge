abstract interface class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object?>? params]);

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty(String name, String? value);

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  Future<void> logScreenView({required String screenName, String? screenClass});

  Future<void> logLogin({String? method});

  Future<void> logSignUp({String? method});
}
