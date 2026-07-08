import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/core/auth/domain/repositories/reset_password_repository.dart';

part 'forgot_password_cubit.freezed.dart';
part 'forgot_password_state.dart';

@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._repo) : super(const ForgotPasswordState());

  final ResetPasswordRepository _repo;

  void resetState() {
    emit(const ForgotPasswordState());
  }

  void emailChanged(String value) {
    final error = validateEmail(value);
    emit(state.copyWith(email: value, emailError: error, apiError: null));
  }

  Future<void> submit() async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _repo.initiate(state.email);
    switch (result) {
      case Success():
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      case Failure(:final error):
        emit(state.copyWith(isSubmitting: false, apiError: error.toString()));
    }
  }
}
