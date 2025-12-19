import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/app/utils/validators/password.dart';

part 'auth_validation_cubit.freezed.dart';
part 'auth_validation_state.dart';

enum AuthMode { signIn, signUp }

@injectable
class AuthValidationCubit extends Cubit<AuthValidationState> {
  AuthValidationCubit() : super(const AuthValidationState());

  void setMode(AuthMode mode) {
    emit(state.copyWith(mode: mode));
    _updateCanSubmit();
  }

  void emailChanged(String email) {
    final error = validateEmail(email);
    emit(state.copyWith(email: email, emailError: error));
    _updateCanSubmit();
  }

  void passwordChanged(String password) {
    final error = validatePassword(password);
    emit(state.copyWith(password: password, passwordError: error));

    if (state.mode == AuthMode.signUp && state.confirmPassword.isNotEmpty) {
      final confirmError = validateConfirmPassword(state.confirmPassword, password);
      emit(state.copyWith(confirmPasswordError: confirmError));
    }

    _updateCanSubmit();
  }

  void confirmPasswordChanged(String confirmPassword) {
    final error = validateConfirmPassword(confirmPassword, state.password);
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        confirmPasswordError: error,
      ),
    );
    _updateCanSubmit();
  }

  // ignore: avoid_positional_boolean_parameters
  void termsAcceptanceChanged(bool accepted) {
    emit(state.copyWith(termsAccepted: accepted));
    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    final baseValidation =
        state.emailError == null && state.passwordError == null && state.email.isNotEmpty && state.password.isNotEmpty;

    bool canSubmit;

    if (state.mode == AuthMode.signIn) {
      canSubmit = baseValidation;
    } else {
      canSubmit =
          baseValidation &&
          state.confirmPasswordError == null &&
          state.confirmPassword.isNotEmpty &&
          state.termsAccepted;
    }

    emit(state.copyWith(canSubmit: canSubmit));
  }
}
