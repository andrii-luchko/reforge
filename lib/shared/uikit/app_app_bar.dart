import 'package:flutter/material.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({this.onPressed, super.key, this.actions});
  final VoidCallback? onPressed;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // iconButton width + padding
      leadingWidth: 56 + 16,
      automaticallyImplyLeading: false,
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

class SliverAppAppBar extends StatelessWidget {
  const SliverAppAppBar({
    this.onPressed,
    this.actions,
    this.title,
    this.pinned = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final List<Widget>? actions;
  final Widget? title;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: pinned,
      centerTitle: false,
      stretch: true,

      leadingWidth: 56,
      leading: onPressed != null
          ? Center(
              child: AppIconButton.icon(
                iconData: Icons.chevron_left_rounded,
                iconSize: 32,
                onPressed: onPressed,
              ),
            )
          : null,

      title: title,
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 16),
            ]
          : null,

      toolbarHeight: kToolbarHeight + 12,
    );
  }
}
