import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/datasources/auth_providers_datasource.dart';
import 'package:reforge/core/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reforge/core/auth/data/enums/auth_providers.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/domain/repositories/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthCanceledException implements Exception {
  const AuthCanceledException();
}

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource, this.authProvidersDatasource);

  final AuthRemoteDataSource remoteDataSource;
  final AuthProvidersDatasource authProvidersDatasource;
  @override
  Future<Result<AuthTokens>> signin(String email, String password) async {
    try {
      final tokens = await remoteDataSource.signin(email, password);
      return Result.success(tokens);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> signup(String email, String password) async {
    try {
      final tokens = await remoteDataSource.signup(email, password);
      return Result.success(tokens);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final tokens = await remoteDataSource.refreshToken(refreshToken);
      return Result.success(tokens);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // final user = await remoteDataSource.getCurrentUser();
      return const Result.success(null);
    } on Exception catch (e) {
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
      final tokens = await remoteDataSource.signWithProvider(token: googleToken, provider: AuthProviders.google);
      logger.d(tokens);
      return const Result.error(AuthCanceledException());
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
      final appleToken = await authProvidersDatasource.signWithApple();
      if (appleToken == null) {
        return Result.error(Exception('Token is empty'));
      }

      final tokens = await remoteDataSource.signWithProvider(token: appleToken, provider: AuthProviders.apple);

      return Result.success(tokens);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Result.error(AuthCanceledException());
      }
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
