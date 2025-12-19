import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AuthRedirectText extends StatelessWidget {
  const AuthRedirectText({
    required this.part1,
    required this.part2,
    required this.onTap,
    super.key,
  });

  final String part2;
  final String part1;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const .only(top: 20),
      child: Text.rich(
        TextSpan(
          text: part1,
          style: subheadH5Medium.copyWith(color: appTheme.beige700, decoration: .underline),

          recognizer: TapGestureRecognizer()..onTap = onTap,

          children: [
            TextSpan(
              text: part2,
              style: subheadH5Medium.copyWith(color: appTheme.beige100),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
