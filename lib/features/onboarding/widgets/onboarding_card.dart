import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/onboarding/widgets/notched_container.dart';
import 'package:reforge/features/onboarding/widgets/onboarding_header.dart';
import 'package:reforge/features/onboarding/widgets/title_text.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaking_widget.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: .spaceBetween,
        children: [
          const OnboardingHeader(),

          ShakingWidget(
            child: Assets.images.png.factions.image(fit: .fill),
          ),

          Align(
            alignment: .bottomCenter,
            child: AspectRatio(
              aspectRatio: 1.1,
              child: NotchedContainer(
                borderGradient: LinearGradient(
                  stops: const [0.1, 0.5, 1],
                  colors: [
                    appTheme.beige100.withValues(alpha: 0),
                    appTheme.beige100,
                    appTheme.beige100.withValues(alpha: 0),
                  ],
                ),

                backgroundGradient: const LinearGradient(
                  begin: .bottomCenter,
                  end: .topCenter,
                  stops: [0.7, 1],
                  colors: [
                    Color(0xFF180D05),
                    Color(0xFF4A2105),
                  ],
                ),

                child: Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const Padding(
                        padding: .only(top: 66, right: 54),
                        child: TitleText(),
                      ),
                      Padding(
                        padding: const .only(top: 20),
                        child: Text(
                          t.onboarding_page.subtitle,
                          style: bodyMRegular.copyWith(color: appTheme.beige700),
                        ),
                      ),

                      Padding(
                        padding: const .only(top: 48),
                        child: PrimaryButton(
                          text: t.onboarding_page.button,
                          //
                          // ignore: inference_failure_on_function_invocation
                          onPressed: () => const SignInPageRoute().push(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
