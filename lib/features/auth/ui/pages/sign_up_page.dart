import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/features/auth/ui/widgets/auth_screen_loader.dart';
import 'package:reforge/features/auth/ui/widgets/forms/sign_up_form.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

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
        loader: const Positioned.fill(child: AuthScreenLoader()),
      ),
    );
  }
}
