import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/network/interceptors/auth_interceptor.dart';
import 'package:reforge/core/network/interceptors/refresh_token_interceptor.dart';

class DioFactory {
  static Dio create({
    required String baseUrl,
    required AuthLocalDataSource localDataSource,
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
        dio,
        localDataSource,
        () async {
          // Just clear tokens, AuthCubit will handle the state change
          await localDataSource.clearTokens();
        },
      ),

      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
    ]);

    return dio;
  }
}
