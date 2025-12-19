import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/splash/ui/widgets/splash_app_logo.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/particles/fire_particles.dart';

import 'package:reforge/shared/animations/shaders/particles_shader.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> navigate(BuildContext context) async {
    await Future.delayed(Durations.long3);

    // ignore: use_build_context_synchronously
    const OnboardingPageRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    unawaited(navigate(context));

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesShaderWidget()),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.smoke.path,
                fit: .fill,
              ),
            ),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.noiseAndTexture.path,
                fit: .fill,
              ),
            ),

            const Center(
              child: Padding(
                padding: .symmetric(horizontal: 98, vertical: 278),
                child: SplashAppLogo(),
              ),
            ),

            const Positioned(
              child: FireParticles(),
            ),
          ],
        ),
      ),
    );
  }
}
