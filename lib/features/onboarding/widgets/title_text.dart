import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = titleH1Medium;
    final textContent = t.onboarding_page.title;

    const shaderRect = Rect.fromLTWH(0, 0, 400, 100);

    return Stack(
      children: [
        Text(
          textContent,
          textAlign: TextAlign.left,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.appTheme.beige100,
                  const Color(0xFF86837D),
                ],
              ).createShader(shaderRect),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              context.appTheme.beige100,
              context.appTheme.beige100.withValues(alpha: 0),
            ],
          ).createShader(bounds),
          child: Text(
            textContent,
            textAlign: TextAlign.left,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
