import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class TierDescription extends StatelessWidget {
  const TierDescription({required this.description, super.key});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appTheme.beige900,
        border: Border.all(
          color: context.appTheme.strokeCard,
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.info_outline_rounded, color: context.appTheme.beige600),
          Expanded(
            child: Text(
              description,
              style: bodyLRegular.copyWith(color: context.appTheme.beige600),
              textAlign: .justify,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut);
  }
}
