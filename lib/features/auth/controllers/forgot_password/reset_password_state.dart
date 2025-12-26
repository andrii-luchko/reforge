part of 'reset_password_cubit.dart';

@freezed
sealed class ResetPasswordState with _$ResetPasswordState {
  const factory ResetPasswordState({
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    String? newPasswordError,
    String? confirmPasswordError,
    String? apiError,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
  }) = _ResetPasswordState;

  const ResetPasswordState._();

  bool get isValid =>
      newPassword.isNotEmpty && confirmPassword.isNotEmpty && newPasswordError == null && confirmPasswordError == null;
}
