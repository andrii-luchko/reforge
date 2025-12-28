import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.text,
    this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final isActive = onPressed != null;
    final borderRadius = BorderRadius.circular(50);

    return GestureDetector(
      onTap: onPressed,
      child: BlurContainer(
        borderRadius: borderRadius,
        child: BaseGlassContainer(
          borderRadius: borderRadius,
          width: double.infinity,
          glassEffectGradientAlignmentBegin: Alignment.topLeft,
          glassEffectGradientAlignmentEnd: Alignment.bottomRight,
          borderGradientStops: const [0.0, 0.1, 0.2, 0.5, 0.8, 1.0],
          borderGradientColors: [
            Colors.transparent,
            appTheme.beige100,
            Colors.transparent,
            appTheme.beige100,
            Colors.transparent,
            appTheme.beige100,
          ],
          borderColor: appTheme.beige100.withValues(alpha: 0.1),
          child: Material(
            borderRadius: borderRadius,
            color: Colors.transparent,
            child: InkWell(
              splashFactory: InkSparkle.splashFactory,
              splashColor: appTheme.beige100.withValues(alpha: 0.1),
              highlightColor: appTheme.beige100.withValues(alpha: 0.01),
              onTap: onPressed,
              child: Padding(
                padding: const .symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    text,
                    style: subheadH5Medium.copyWith(
                      color: isActive ? appTheme.beige100 : appTheme.beige700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
