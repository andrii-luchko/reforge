import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(50);
    final isActive = onPressed != null;
    final appTheme = context.appTheme;
    return Material(
      color: isActive ? appTheme.orangeButton : appTheme.beige800,
      borderRadius: borderRadius,

      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashFactory: InkSparkle.splashFactory,
        splashColor: appTheme.orange100.withValues(alpha: 0.2),
        highlightColor: appTheme.orange100.withValues(alpha: 0.1),

        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CustomPaint(
            painter: DashedBorderPainter(color: isActive ? appTheme.orange300 : appTheme.beige700),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? appTheme.orange400 : appTheme.beige800,
                borderRadius: borderRadius,
              ),
              child: Center(
                child: Text(
                  text,
                  style: subheadH5Medium.copyWith(
                    color: appTheme.beige100,
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
