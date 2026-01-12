import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

class ScreenLoadingIndicator extends StatelessWidget {
  const ScreenLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.appTheme.beige1000.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.appTheme.beige900,
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
