import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_screen_loader.dart';
import 'package:reforge/features/auth/ui/widgets/forms/sign_up_form.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesShaderWidget()),
            Positioned.fill(
              child: Image.asset(
                Assets.images.png.smoke.path,
                fit: .fill,
                opacity: const AlwaysStoppedAnimation<double>(0.5),
              ),
            ),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.noiseAndTexture.path,
                fit: .fill,
              ),
            ),

            Positioned.fill(
              child: SunRaysShaderWidget(
                color: appTheme.orange500,
                alignment: const Alignment(0, -1.2),
                intensity: 1,
                density: 5,
                rayLength: 0.6,
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const .symmetric(horizontal: 16),
                child: BlocProvider(
                  create: (context) => di.getIt<AuthValidationCubit>()..setMode(AuthMode.signUp),
                  child: const SafeArea(child: SignUpForm()),
                ),
              ),
            ),
            const Positioned.fill(child: AuthScreenLoader()),
          ],
        ),
      ),
    );
  }
}
