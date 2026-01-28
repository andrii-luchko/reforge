import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/auth/controllers/forgot_password/reset_password_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/forms/create_new_password_form.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class CreateNewPasswordPage extends StatelessWidget {
  const CreateNewPasswordPage({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
      ),

      body: BlocProvider(
        create: (context) => di.getIt<ResetPasswordCubit>(param1: token),
        child: DefaultBackground(
          body: const Positioned.fill(
            child: Padding(
              padding: .symmetric(horizontal: 16),
              child: SafeArea(child: CreateNewPasswordForm()),
            ),
          ),

          additionalAnimationsOnTop: [
            Positioned.fill(
              child: SunRaysShaderWidget.fromTop(
                color: appTheme.orange500,
              ),
            ),
          ],
          loader: const Positioned.fill(child: _CreatePasswordLoader()),
        ),
      ),
    );
  }
}

class _CreatePasswordLoader extends StatelessWidget {
  const _CreatePasswordLoader();
  @override
  Widget build(BuildContext context) {
    return BlocSelector<ResetPasswordCubit, ResetPasswordState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        if (!isSubmitting) return const SizedBox.shrink();

        return const Center(child: ScreenLoadingIndicator());
      },
    );
  }
}
