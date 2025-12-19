part of 'forgot_password_cubit.dart';

@freezed
sealed class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    @Default(ForgotPasswordMode.email) ForgotPasswordMode mode,
    @Default('') String email,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    String? emailError,
    String? newPasswordError,
    String? confirmPasswordError,
    @Default(false) bool canSubmit,
  }) = _ForgotPasswordState;
}
