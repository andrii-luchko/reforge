import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/domain/repositories/auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

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
}
