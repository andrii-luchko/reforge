import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDoneButton extends StatelessWidget {
  const WorkoutDoneButton._({
    required this.onTap,
    required this.isDone,
    String? text,
    IconData? icon,
    super.key,
  }) : _text = text,
       _icon = icon;

  const WorkoutDoneButton.text({
    required String text,
    required bool isDone,
    VoidCallback? onTap,

    Key? key,
  }) : this._(
         onTap: onTap,
         isDone: isDone,
         text: text,
         key: key,
       );

  const WorkoutDoneButton.icon({
    required bool isDone,
    VoidCallback? onTap,
    IconData icon = Icons.check,
    Key? key,
  }) : this._(
         onTap: onTap,
         isDone: isDone,
         icon: icon,
         key: key,
       );

  final VoidCallback? onTap;
  final bool isDone;
  final String? _text;
  final IconData? _icon;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final contentColor = appTheme.beige100;

    return Skeleton.leaf(
      child: Material(
        borderRadius: appTheme.workoutContainerBorderRadius,

        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: PressableAnimation(
          scaleAmount: 0.99,
          onTap: onTap,
          child: AnimatedContainer(
            duration: Durations.medium2,
            constraints: appTheme.workoutContainerConstrains,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDone ? appTheme.beige800 : appTheme.orange400,
              borderRadius: appTheme.workoutContainerBorderRadius,
            ),
            child: Center(
              child: _buildContent(contentColor),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: avoid_returning_widgets
  Widget _buildContent(Color color) {
    return _text != null
        ? Text(
            _text,
            style: subheadH3Medium.copyWith(color: color),
            textAlign: TextAlign.center,
          )
        : Icon(_icon, size: 24, color: color);
  }
}
