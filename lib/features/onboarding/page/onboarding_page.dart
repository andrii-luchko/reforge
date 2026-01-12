import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/features/onboarding/widgets/onboarding_card.dart';
import 'package:reforge/shared/animations/particles/fire_particles.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      body: DefaultBackground(
        body: const OnboardingCard(),
        additionalAnimations: [
          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              alignment: const Alignment(-3, -2),
              intensity: 1,
            ),
          ),

          const Align(
            alignment: Alignment(0, -0.4),
            child: AspectRatio(
              aspectRatio: 1,
              child: RepaintBoundary(
                child: FireParticles(),
              ),
            ),
          ),

          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              rayLength: 0.35,
              density: 6,
              intensity: 5,
              alignment: const Alignment(0, 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
