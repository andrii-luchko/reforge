import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/requests/password_reset_confirm_req.dart';
import 'package:reforge/core/auth/data/requests/password_reset_email_req.dart';
import 'package:reforge/core/auth/data/requests/password_reset_validate_token_req.dart';
import 'package:reforge/core/auth/domain/repositories/reset_password_repository.dart';
import 'package:reforge/core/network/api_client.dart';

@Injectable(as: ResetPasswordRepository)
class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  ResetPasswordRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<void>> initiate(String email) async {
    try {
      await _apiClient.initiatePasswordReset(PasswordResetEmailRequest(email: email));
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> validate(String token) async {
    try {
      await _apiClient.validatePasswordReset(PasswordResetValidateTokenRequest(token: token));
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> confirm({required String token, required String newPassword}) async {
    try {
      await _apiClient.confirmPasswordReset(PasswordResetConfirmRequest(token: token, newPassword: newPassword));
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
