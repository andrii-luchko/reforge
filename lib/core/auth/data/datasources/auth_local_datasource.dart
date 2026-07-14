import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
  Future<bool> hasAccessToken();
}

const _keyAccessToken = 'access_token';
const _keyRefreshToken = 'refresh_token';

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await Future.wait([
      _secureStorage.write(key: _keyAccessToken, value: tokens.accessToken),
      _secureStorage.write(key: _keyRefreshToken, value: tokens.refreshToken),
    ]);
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final results = await Future.wait([
      _secureStorage.read(key: _keyAccessToken),
      _secureStorage.read(key: _keyRefreshToken),
    ]);

    final accessToken = results[0];
    final refreshToken = results[1];

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _keyAccessToken),
      _secureStorage.delete(key: _keyRefreshToken),
    ]);
  }

  @override
  Future<bool> hasAccessToken() async {
    return _secureStorage.containsKey(key: _keyAccessToken);
  }
}
