import 'package:reforge/app/utils/helpers/result.dart';

abstract interface class ResetPasswordRepository {
  Future<Result<void>> initiate(String email);
  Future<Result<void>> validate(String token);
  Future<Result<void>> confirm({required String token, required String newPassword});
}
