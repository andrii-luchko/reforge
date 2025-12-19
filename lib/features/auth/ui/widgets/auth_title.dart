import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AuthTitle extends StatelessWidget {
  const AuthTitle({required this.subtitle, required this.title, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),

        Padding(
          padding: const .only(top: 16),
          child: Text(
            textAlign: .center,
            subtitle,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
        ),
      ],
    );
  }
}
