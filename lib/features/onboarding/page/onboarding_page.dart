import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/onboarding/widgets/onboarding_card.dart';
import 'package:reforge/shared/animations/particles/fire_particles.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      body: DefaultBackground(
        body: const OnboardingCard(),

        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.fromTop(color: appTheme.orange500),
          ),
          const Align(
            alignment: Alignment(0, -0.4),
            child: AspectRatio(
              aspectRatio: 1,
              child: FireParticles(),
            ),
          ),
          Positioned.fill(
            child: SunRaysShaderWidget(
              color: appTheme.orange500,
              rayLength: 0.065,
              intensity: 3,
              density: 3,
              alignment: const Alignment(0, 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
