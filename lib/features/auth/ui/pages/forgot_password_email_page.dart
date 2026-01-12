import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/forms/forgot_password_email_form.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class ForgotPasswordEmailPage extends StatelessWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
      ),

      body: DefaultBackground(
        body: const Positioned.fill(
          child: Padding(
            padding: .symmetric(horizontal: 16),
            child: SafeArea(child: ForgotPasswordEmailForm()),
          ),
        ),

        additionalAnimations: [
          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              alignment: const Alignment(0, -1.2),
              intensity: 1,
              density: 5,
              rayLength: 0.6,
            ),
          ),
        ],
        loader: const Positioned.fill(child: ForgotPasswordLoader()),
      ),
    );
  }
}

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
