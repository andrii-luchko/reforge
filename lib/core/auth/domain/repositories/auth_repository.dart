import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthTokens>> signin(String email, String password);

  Future<Result<AuthTokens>> signup(String email, String password);

  Future<Result<AuthTokens>> signWithGoogle();
  Future<Result<AuthTokens>> signWithApple();

  Future<Result<AuthTokens>> refreshToken(String refreshToken);
  Future<Result<User?>> getCurrentUser();
}
