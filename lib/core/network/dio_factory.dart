import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/session/auth_session_controller.dart';
import 'package:reforge/core/auth/session/token_refresh_service.dart';
import 'package:reforge/core/network/interceptors/auth_interceptor.dart';
import 'package:reforge/core/network/interceptors/refresh_token_interceptor.dart';

class DioFactory {
  static Dio create({
    required String baseUrl,
    required AuthLocalDataSource localDataSource,
    required AuthSessionController sessionController,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(localDataSource),

      RefreshTokenInterceptor(
        dio: dio,
        localDataSource: localDataSource,
        tokenRefreshService: TokenRefreshService(
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
          localDataSource,
        ),
        sessionController: sessionController,
      ),

      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          requestHeader: false,
          responseHeader: false,
          responseBody: true,
        ),
    ]);

    return dio;
  }
}
