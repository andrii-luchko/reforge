final class Env {
  Env._();
  static const termsOfUseUrl = String.fromEnvironment('TERMS_OF_USE_URL');
  static const apiBaseUrl = String.fromEnvironment('BASE_API_URL');

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
