import 'package:dio/dio.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/network/api_extra_keys.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._localDataSource);
  final AuthLocalDataSource _localDataSource;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra[ApiExtraKeys.requiresAuth] as bool? ?? true;

    if (!requiresAuth) {
      return handler.next(options);
    }

    final tokens = await _localDataSource.getTokens();

    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }

    handler.next(options);
  }
}
