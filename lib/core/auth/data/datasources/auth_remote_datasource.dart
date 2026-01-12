import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/enums/auth_providers.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/data/requests/refresh_token_request.dart';
import 'package:reforge/core/auth/data/requests/sign_up_request.dart';
import 'package:reforge/core/auth/data/requests/sign_with_provider_request.dart';
import 'package:reforge/core/auth/data/requests/signin_request.dart';
import 'package:reforge/core/network/api_client.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthTokens> signin(String email, String password);
  Future<AuthTokens> signup(String email, String password);

  Future<AuthTokens> signWithProvider({
    required String token,
    required AuthProviders provider,
    String? firstName,
    String? lastName,
  });

  Future<AuthTokens> refreshToken(String refreshToken);
  Future<User> getCurrentUser();
  Future<void> logout();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthTokens> signin(String email, String password) async {
    final response = await _apiClient.signin(
      SignInRequest(email: email, password: password),
    );
    return response.data;
  }

  @override
  Future<AuthTokens> signup(String email, String password) async {
    final response = await _apiClient.signup(
      SignUpRequest(email: email, password: password),
    );
    return response.data;
  }

  @override
  Future<AuthTokens> signWithProvider({
    required String token,
    required AuthProviders provider,
    String? firstName,
    String? lastName,
  }) async {
    final requestBody = SignWithProviderRequest(
      token: token,
      provider: provider,
      firstName: firstName,
      lastName: lastName,
    );
    final response = await _apiClient.provider(requestBody);

    return response.data;
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _apiClient.refreshToken(
      RefreshTokenRequest(refreshToken: refreshToken),
    );
    return response.data;
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await _apiClient.getCurrentUser();
    return response.data;
  }

  @override
  Future<void> logout() async {
    await _apiClient.logout();
  }
}
