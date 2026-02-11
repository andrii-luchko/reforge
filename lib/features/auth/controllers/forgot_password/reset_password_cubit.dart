import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/password.dart';
import 'package:reforge/core/auth/domain/repositories/reset_password_repository.dart';

part 'reset_password_state.dart';
part 'reset_password_cubit.freezed.dart';

@injectable
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(
    @factoryParam this.token,
    this._repo,
  ) : super(const ResetPasswordState());

  final ResetPasswordRepository _repo;
  final String token;

  void passwordChanged(String value) {
    final error = validatePassword(value);
    var confirmErr = state.confirmPasswordError;
    if (state.confirmPassword.isNotEmpty) {
      confirmErr = validateConfirmPassword(state.confirmPassword, value);
    }

    emit(state.copyWith(newPassword: value, newPasswordError: error, confirmPasswordError: confirmErr));
  }

  void confirmPasswordChanged(String value) {
    final error = validateConfirmPassword(value, state.newPassword);
    emit(state.copyWith(confirmPassword: value, confirmPasswordError: error));
  }

  Future<void> submit() async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _repo.confirm(token: token, newPassword: state.newPassword);

    switch (result) {
      case Success():
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      case ErrorR(error: final error):
        emit(state.copyWith(isSubmitting: false, apiError: error.toString()));
    }
  }
}
