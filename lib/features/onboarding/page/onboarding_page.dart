import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/onboarding/widgets/onboarding_card.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/particles/fire_particles.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            SunRaysShaderWidget(
              color: appTheme.orange500,
              alignment: const Alignment(-3, -2),
              intensity: 1,
              density: 10,
              rayLength: 5.5,
            ),

            const Positioned.fill(
              child: ParticlesShaderWidget(),
            ),

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

            const Align(
              alignment: Alignment(0, -0.4),
              child: AspectRatio(aspectRatio: 1, child: RepaintBoundary(child: FireParticles())),
            ),

            SunRaysShaderWidget(
              color: appTheme.orange500,
              rayLength: 0.5,
              density: 6,
              intensity: 5,
              alignment: const Alignment(0, 0.4),
            ),

            const OnboardingCard(),
          ],
        ),
      ),
    );
  }
}
