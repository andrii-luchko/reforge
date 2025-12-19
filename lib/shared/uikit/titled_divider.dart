import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class TitledDivider extends StatelessWidget {
  const TitledDivider({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final divider = Expanded(
      child: Divider(
        color: context.appTheme.strokeCard,
      ),
    );

    return Row(
      children: [
        divider,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(title, style: subheadH5Medium.copyWith(color: context.appTheme.beige100)),
        ),
        divider,
      ],
    );
  }
}
