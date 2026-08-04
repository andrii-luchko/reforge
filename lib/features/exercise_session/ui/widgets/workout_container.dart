import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class WorkoutContainer extends StatelessWidget {
  const WorkoutContainer({
    required this.text,
    this.onTap,
    this.height,
    this.width,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final isActive = onTap != null;
    return PressableAnimation(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Durations.medium2,
        curve: Curves.easeInOut,
        width: width,
        height: height,
        constraints: appTheme.workoutContainerConstrains,
        decoration: BoxDecoration(
          borderRadius: appTheme.workoutContainerBorderRadius,
          color: appTheme.beige900,
        ),
        child: Center(
          child: Text(
            text,
            style: subheadH3Medium.copyWith(color: isActive ? appTheme.beige100 : appTheme.beige700),
          ),
        ),
      ),
    );
  }
}
