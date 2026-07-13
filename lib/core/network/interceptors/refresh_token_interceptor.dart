import 'package:dio/dio.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/session/auth_session_controller.dart';
import 'package:reforge/core/auth/session/token_refresh_service.dart';
import 'package:reforge/core/network/api_extra_keys.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required AuthLocalDataSource localDataSource,
    required TokenRefreshService tokenRefreshService,
    required AuthSessionController sessionController,
  }) : _dio = dio,
       _localDataSource = localDataSource,
       _tokenRefreshService = tokenRefreshService,
       _sessionController = sessionController;

  final Dio _dio;
  final AuthLocalDataSource _localDataSource;
  final TokenRefreshService _tokenRefreshService;
  final AuthSessionController _sessionController;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final requiresAuth = options.extra[ApiExtraKeys.requiresAuth] as bool? ?? true;

    if (!requiresAuth || err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final retryCount = options.extra[ApiExtraKeys.retryCount] as int? ?? 0;
    if (retryCount > 0) {
      return handler.next(err);
    }

    final currentTokens = await _localDataSource.getTokens();
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await _sessionController.invalidate(SessionEndReason.refreshTokenInvalid);
      return handler.reject(err);
    }

    final sentAccessToken = options.extra[ApiExtraKeys.sentAccessToken] as String?;
    var accessToken = currentTokens.accessToken;

    if (sentAccessToken == null || sentAccessToken == currentTokens.accessToken) {
      try {
        accessToken = (await _tokenRefreshService.refresh()).accessToken;
      } on DioException catch (refreshError) {
        if (_isInvalidRefreshToken(refreshError)) {
          await _sessionController.invalidate(SessionEndReason.refreshTokenInvalid);
        }
        return handler.reject(refreshError);
      } on RefreshTokenUnavailableException {
        await _sessionController.invalidate(SessionEndReason.refreshTokenInvalid);
        return handler.reject(err);
      } on FormatException {
        return handler.reject(err);
      } on Object {
        return handler.reject(err);
      }
    }

    try {
      final response = await _retry(options, accessToken, retryCount + 1);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.reject(retryError);
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String accessToken,
    int retryCount,
  ) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[ApiExtraKeys.sentAccessToken] = accessToken;
    options.extra[ApiExtraKeys.retryCount] = retryCount;

    if (options.data case final FormData formData) {
      options.data = formData.clone();
    }

    return _dio.fetch<dynamic>(options);
  }

  bool _isInvalidRefreshToken(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }
}
