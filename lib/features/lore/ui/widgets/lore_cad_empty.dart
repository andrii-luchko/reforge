import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class LoreCardEmpty extends StatelessWidget {
  const LoreCardEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: context.appTheme.orange500,
            ),
            const SizedBox(height: 16),
            Text(
              t.lore.contentPlaceholder,
              textAlign: TextAlign.center,
              style: subheadH6Regular.copyWith(
                color: context.appTheme.beige600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
