import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,

      children: [
        BlurContainer(
          child: GlassContainer(
            child: Padding(
              padding: const .symmetric(horizontal: 20, vertical: 16),
              child: SvgPicture.asset(Assets.images.svg.logo),
            ),
          ),
        ),
        Padding(
          padding: .only(top: 16),
          child: Text(
            t.onboarding_page.header,
            style: subheadH3Medium.copyWith(color: context.appTheme.beige700),
          ),
        ),
      ],
    );
  }
}
