import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

extension CustomToast on Toastification {
  ToastificationItem showCustomToast(ToastificationBuilder builder) {
    return toastification.showCustom(
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topRight,
      dismissDirection: DismissDirection.none,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },

      builder: builder,
    );
  }

  ToastificationItem showErrorToast(String text, BuildContext context) {
    return toastification.show(
      type: .error,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: .topCenter,
      title: Text(
        text,
        maxLines: 3,
        overflow: .ellipsis,
      ),

      backgroundColor: context.appTheme.beige900,
      foregroundColor: context.appTheme.beige100,
      borderSide: BorderSide(color: context.appTheme.strokeCard),
    );
  }
}
