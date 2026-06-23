import 'package:dio/dio.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reforge/core/network/api_extra_keys.dart';

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
    final options = err.requestOptions;
    final requiresAuth = options.extra[ApiExtraKeys.requiresAuth] as bool? ?? true;
    final isRefreshRequest = options.extra[ApiExtraKeys.authRefreshRequest] as bool? ?? false;

    // Do not attempt to refresh for requests that explicitly don't require auth
    // or for the refresh-token request itself.
    if (!requiresAuth || isRefreshRequest) {
      if (isRefreshRequest) {
        await _localDataSource.clearTokens();
        onTokenRefreshFailed();
      }

      return handler.reject(err);
    }

    if (err.response?.statusCode == 401) {
      try {
        final tokens = await _localDataSource.getTokens();

        if (tokens == null || tokens.refreshToken.isEmpty) {
          onTokenRefreshFailed();
          return handler.reject(err);
        }

        final newTokens = await _remoteDataSource
            .refreshToken(tokens.refreshToken)
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () => throw DioException.receiveTimeout(
                timeout: const Duration(seconds: 20),
                requestOptions: err.requestOptions,
              ),
            );
        await _localDataSource.saveTokens(newTokens);

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

        final requestData = options.data;
        if (requestData is FormData) {
          options.data = requestData.clone();
        }

        final response = await _dio.fetch<dynamic>(options);
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
