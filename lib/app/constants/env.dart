final class Env {
  Env._();
  static const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  static const termsOfUseUrl = String.fromEnvironment('TERMS_OF_USE_URL');

  static const apiBaseUrl = String.fromEnvironment('BASE_API_URL');

  static const revenuecatApiKeyApple = String.fromEnvironment('REVENUECAT_API_KEY_APPLE');
  static const revenuecatApiKeyGoogle = String.fromEnvironment('REVENUECAT_API_KEY_GOOGLE');
  static const revenuecatApiKeyTest = String.fromEnvironment('REVENUECAT_API_KEY_TEST');

  static const appleAuthServiceID = String.fromEnvironment('APPLE_AUTH_SERVICE_ID');
  static const appleAuthServiceURL = String.fromEnvironment('APP_AUTH_SERVICE_URL');

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
