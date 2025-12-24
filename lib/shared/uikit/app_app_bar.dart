import 'package:flutter/material.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({required this.onPressed, super.key, this.actions});
  final VoidCallback? onPressed;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // iconButton width + padding
      leadingWidth: 56 + 16,

      leading: onPressed != null
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: AppIconButton.icon(
                iconData: Icons.chevron_left_rounded,
                iconSize: 32,
                onPressed: onPressed,
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight + 12);
}
