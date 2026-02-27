import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/datasources/auth_providers_datasource.dart';
import 'package:reforge/core/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reforge/core/auth/data/enums/auth_providers.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/domain/repositories/auth_repository.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthCanceledException implements AppException {
  const AuthCanceledException();

  @override
  String get message => '';
}

@Injectable(as: AuthRepository)
class AuthRepositoryImpl with RepositoryErrorHandler implements AuthRepository {
  AuthRepositoryImpl(
    this.remoteDataSource,
    this.authProvidersDatasource,
    this.localDataSource,
  );

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AuthProvidersDatasource authProvidersDatasource;

  @override
  Future<Result<AuthTokens?>> getTokens() async {
    try {
      final localTokens = await localDataSource.getTokens();
      if (localTokens == null) {
        return const Result.success(null);
      } else {
        final refreshedTokens = await refreshToken(localTokens.refreshToken);

        switch (refreshedTokens) {
          case Success(value: final value):
            return Result.success(value);
          case ErrorR(error: final error):
            if (error is DioException) {
              if (error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  error.type == DioExceptionType.connectionError ||
                  error.error is SocketException) {
                return Result.success(localTokens);
              }
            }

            return const Result.success(null);
        }
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> clearTokens() async {
    try {
      await localDataSource.clearTokens();
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> signin(String email, String password) async {
    try {
      final tokens = await makeRequest(
        () async {
          final t = await remoteDataSource.signin(email, password);
          await localDataSource.saveTokens(t);
          return t;
        },
        label: 'signin',
      );
      return Result.success(tokens);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> signup(String email, String password) async {
    try {
      final tokens = await makeRequest(
        () async {
          final t = await remoteDataSource.signup(email, password);
          await localDataSource.saveTokens(t);
          return t;
        },
        label: 'signup',
      );
      return Result.success(tokens);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await authProvidersDatasource.logout();
      await localDataSource.clearTokens();
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final tokens = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(tokens);
      return Result.success(tokens);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        await localDataSource.clearTokens();
      }

      return Result.error(e);
    } on Exception catch (e) {
      await localDataSource.clearTokens();
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> signWithGoogle() async {
    try {
      final googleToken = await authProvidersDatasource.signWithGoogle();
      if (googleToken == null) {
        return Result.error(Exception('Token is empty'));
      }
      final tokens = await makeRequest(
        () async {
          final t = await remoteDataSource.signWithProvider(
            token: googleToken,
            provider: AuthProviders.google,
          );
          await localDataSource.saveTokens(t);
          return t;
        },
        label: 'signWithGoogle',
      );
      return Result.success(tokens);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Result.error(AuthCanceledException());
      }
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> signWithApple() async {
    try {
      final data = await authProvidersDatasource.signWithApple();
      if (data.token == null) {
        return Result.error(Exception('Token is empty'));
      }
      final tokens = await makeRequest(
        () async {
          final t = await remoteDataSource.signWithProvider(
            token: data.token!,
            provider: AuthProviders.apple,
            firstName: data.name,
            lastName: data.surname,
          );
          await localDataSource.saveTokens(t);
          return t;
        },
        label: 'signWithApple',
      );
      return Result.success(tokens);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Result.error(AuthCanceledException());
      }
      logger.d(e);
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
