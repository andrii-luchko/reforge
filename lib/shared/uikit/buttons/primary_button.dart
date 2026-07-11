import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    this.onPressed,
    this.iconAsset,
    super.key,
  });

  final String text;
  final String? iconAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(50);
    final isActive = onPressed != null;
    final appTheme = context.appTheme;

    final icon = iconAsset == null
        ? null
        : Padding(
            padding: const .only(right: 8),
            child: AppSvgIcon(
              asset: iconAsset!,
              size: 20,
            ),
          );
    return PressableAnimation(
      scaleAmount: 0.98,
      onTap: isActive ? () {} : null,
      child: Material(
        color: isActive ? appTheme.orangeButton : appTheme.beige800,
        borderRadius: borderRadius,

        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: appTheme.buttonConstrains,
          child: InkWell(
            enableFeedback: false,
            onTap: onPressed,
            splashFactory: InkSparkle.splashFactory,
            splashColor: appTheme.orange100.withValues(alpha: 0.2),
            highlightColor: appTheme.orange100.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(color: isActive ? appTheme.orange300 : appTheme.beige700),
                child: AnimatedContainer(
                  duration: Durations.medium2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isActive ? appTheme.orange400 : appTheme.beige800,
                    borderRadius: borderRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: .center,
                    mainAxisSize: .min,
                    children: [
                      ?icon,
                      Text(
                        text,
                        style: subheadH5Medium.copyWith(
                          color: appTheme.beige100,
                        ),
                      ),
                    ],
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
