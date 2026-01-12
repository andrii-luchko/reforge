import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class ForgotPasswordLoader extends StatelessWidget {
  const ForgotPasswordLoader({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        if (!isSubmitting) return const SizedBox.shrink();

        return const Center(child: ScreenLoadingIndicator());
      },
    );
  }
}
