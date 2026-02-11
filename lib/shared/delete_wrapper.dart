import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reforge/app/theme/app_theme.dart';

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
          SlidableAction(
            onPressed: onPressed,
            backgroundColor: theme.beige900,
            foregroundColor: theme.beige100,
            icon: Icons.delete,
            label: label,
            borderRadius: theme.workoutContainerBorderRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}
