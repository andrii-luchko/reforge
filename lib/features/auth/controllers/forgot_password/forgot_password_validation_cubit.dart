import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/app/utils/validators/password.dart';

part 'forgot_password_validation_cubit.freezed.dart';
part 'forgot_password_validation_state.dart';

enum ForgotPasswordMode { email, createPassword }

@injectable
class ForgotPasswordValidationCubit extends Cubit<ForgotPasswordValidationState> {
  ForgotPasswordValidationCubit() : super(const ForgotPasswordValidationState());

  void setMode(ForgotPasswordMode mode) {
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
    emit(state.copyWith(newPassword: password, newPasswordError: error));

    if (state.mode == ForgotPasswordMode.createPassword && state.confirmPassword.isNotEmpty) {
      final confirmError = validateConfirmPassword(state.confirmPassword, password);
      emit(state.copyWith(confirmPasswordError: confirmError));
    }

    _updateCanSubmit();
  }

  void confirmPasswordChanged(String confirmPassword) {
    final error = validateConfirmPassword(confirmPassword, state.newPassword);
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        confirmPasswordError: error,
      ),
    );
    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    final baseValidation = state.emailError == null && state.email.isNotEmpty;

    bool canSubmit;

    if (state.mode == ForgotPasswordMode.email) {
      canSubmit = baseValidation;
    } else {
      canSubmit =
          state.newPasswordError == null &&
          state.newPassword.isNotEmpty &&
          state.confirmPasswordError == null &&
          state.confirmPassword.isNotEmpty;
    }

    emit(state.copyWith(canSubmit: canSubmit));
  }
}
