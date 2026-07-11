import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

class AppDialog<T> extends StatelessWidget {
  const AppDialog._({
    required this.child,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    Color? backgroundColor,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismissible',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AppDialog._(
            backgroundColor: backgroundColor,
            child: child,
          ),
        );
      },

      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutQuart.transform(anim1.value);

        return Transform.scale(
          scale: 0.9 + (0.1 * curvedValue),
          child: Opacity(
            opacity: curvedValue,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Dialog(
      insetPadding: const .symmetric(horizontal: 16),
      backgroundColor: backgroundColor ?? appTheme.beige900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: appTheme.strokeCard),
      ),
      child: child,
    );
  }
}
