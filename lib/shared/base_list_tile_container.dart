import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';

class BaseListTileContainer extends StatelessWidget {
  const BaseListTileContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: appTheme.cardNavigation,

        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      child: child,
    );
  }
}
