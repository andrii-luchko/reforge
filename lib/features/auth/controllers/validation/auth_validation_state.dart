part of 'auth_validation_cubit.dart';

@freezed
sealed class AuthValidationState with _$AuthValidationState {
  const factory AuthValidationState({
    @Default(AuthMode.signIn) AuthMode mode,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
  }) = _AuthValidationState;
}
