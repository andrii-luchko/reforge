part of 'forgot_password_validation_cubit.dart';

@freezed
sealed class ForgotPasswordValidationState with _$ForgotPasswordValidationState {
  const factory ForgotPasswordValidationState({
    @Default(ForgotPasswordMode.email) ForgotPasswordMode mode,
    @Default('') String email,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    String? emailError,
    String? newPasswordError,
    String? confirmPasswordError,
    @Default(false) bool canSubmit,
  }) = _ForgotPasswordValidationState;
}
