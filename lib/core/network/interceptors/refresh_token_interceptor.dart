import 'package:dio/dio.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/datasources/auth_remote_datasource.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor(
    this._dio,
    this._localDataSource,
    this.onTokenRefreshFailed,
  );

  final Dio _dio;
  final AuthLocalDataSource _localDataSource;
  final void Function() onTokenRefreshFailed;
  
  // Lazy getter to avoid circular dependency
  AuthRemoteDataSource get _remoteDataSource => di.getIt<AuthRemoteDataSource>();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final tokens = await _localDataSource.getTokens();

        if (tokens == null || tokens.refreshToken.isEmpty) {
          onTokenRefreshFailed();
          return handler.reject(err);
        }

        final newTokens = await _remoteDataSource.refreshToken(tokens.refreshToken);
        await _localDataSource.saveTokens(newTokens);

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

        // ignore: inference_failure_on_function_invocation
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } on Exception catch (_) {
        await _localDataSource.clearTokens();
        onTokenRefreshFailed();
        return handler.reject(err);
      }
    }

    handler.next(err);
  }
}
