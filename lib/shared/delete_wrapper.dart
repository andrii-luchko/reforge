import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class DeleteWrapper extends StatelessWidget {
  const DeleteWrapper({
    required this.child,
    required this.enabled,
    required this.onPressed,
    required super.key,

    required this.label,
  });

  final bool enabled;
  final void Function(BuildContext context)? onPressed;
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Slidable(
      enabled: enabled,
      key: key,

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Expanded(
            child: _NoSplashDeleteAction(
              onPressed: onPressed,
              backgroundColor: theme.beige900,
              foregroundColor: theme.beige100,

              icon: Icons.delete,
              label: label,
              borderRadius: theme.workoutContainerBorderRadius,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NoSplashDeleteAction extends StatelessWidget {
  const _NoSplashDeleteAction({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    required this.borderRadius,
    required this.icon,
  });

  final void Function(BuildContext context)? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final BorderRadius borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PressableAnimation(
      onTap: () {
        onPressed?.call(context);
        unawaited(Slidable.of(context)?.close());
      },

      child: Container(
        margin: const .only(left: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: foregroundColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
