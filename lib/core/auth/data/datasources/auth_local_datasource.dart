import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
  Future<bool> hasAccessToken();

  Future<bool> isQuizFinished();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<bool> isQuizFinished() async {
    final isQuizFinished = await _secureStorage.read(key: 'quiz_finished');

    return bool.parse(isQuizFinished ?? 'false');
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await _secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);
    // await _secureStorage.write(key: 'expires_at', value: tokens.expiresAt.toIso8601String());
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    // final expiresAtStr = await _secureStorage.read(key: 'expires_at');

    // if (accessToken == null || refreshToken == null || expiresAtStr == null) {
    //   return null;
    // }
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      // expiresAt: DateTime.parse(expiresAtStr),
    );
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }
}
