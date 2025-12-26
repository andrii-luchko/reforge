part of 'forgot_password_cubit.dart';

@freezed
sealed class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    @Default('') String email,
    String? emailError,
    String? apiError,
    @Default(false) bool canSubmit,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
  }) = _ForgotPasswordState;
  const ForgotPasswordState._();

  bool get isValid => email.isNotEmpty && emailError == null;
}
