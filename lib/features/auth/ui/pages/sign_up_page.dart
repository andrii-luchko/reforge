import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_screen_loader.dart';
import 'package:reforge/features/auth/ui/widgets/forms/sign_up_form.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      body: DefaultBackground(
        body: Positioned.fill(
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: BlocProvider(
              create: (context) => di.getIt<AuthValidationCubit>()..setMode(AuthMode.signUp),
              child: const SafeArea(child: SignUpForm()),
            ),
          ),
        ),
        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.fromTop(
              color: appTheme.orange500,
            ),
          ),
        ],
        loader: const Positioned.fill(child: AuthScreenLoader()),
      ),
    );
  }
}
