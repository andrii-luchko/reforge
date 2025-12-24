import 'package:dio/dio.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._localDataSource);
  final AuthLocalDataSource _localDataSource;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await _localDataSource.getTokens();

    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }

    handler.next(options);
  }
}
