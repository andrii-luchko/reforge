import 'package:dio/dio.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/requests/refresh_token_request.dart';

class TokenRefreshService {
  TokenRefreshService(this._dio, this._localDataSource);

  final Dio _dio;
  final AuthLocalDataSource _localDataSource;
  Future<AuthTokens>? _refreshFuture;

  Future<AuthTokens> refresh() {
    return _refreshFuture ??= _refresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<AuthTokens> _refresh() async {
    final tokens = await _localDataSource.getTokens();
    if (tokens == null || tokens.refreshToken.isEmpty) {
      throw const RefreshTokenUnavailableException();
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: RefreshTokenRequest(refreshToken: tokens.refreshToken).toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw const FormatException('Refresh response is empty');
    }

    final newTokens = BaseResponse<AuthTokens>.fromJson(
      body,
      (json) => AuthTokens.fromJson(json! as Map<String, dynamic>),
    ).data;
    await _localDataSource.saveTokens(newTokens);
    return newTokens;
  }
}

class RefreshTokenUnavailableException implements Exception {
  const RefreshTokenUnavailableException();
}
