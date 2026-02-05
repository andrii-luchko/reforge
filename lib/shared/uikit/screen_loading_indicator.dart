import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

class ScreenLoadingIndicator extends StatelessWidget {
  const ScreenLoadingIndicator({
    super.key,
    this.padding = const EdgeInsets.all(32),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.appTheme.beige1000.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: padding,
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
