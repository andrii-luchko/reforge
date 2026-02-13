import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/ui/widgets/notification_list_tile.dart';
import 'package:reforge/shared/uikit/toasts/app_simple_toast.dart';
import 'package:toastification/toastification.dart';

extension CustomToast on Toastification {
  ToastificationItem showNotificationToast(NotificationEntity notification) {
    return toastification.showCustom(
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topRight,
      dismissDirection: DismissDirection.none,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      builder: (context, item) {
        return Align(
          alignment: item.alignment,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => toastification.dismiss(item),
              child: NotificationListTile(notification: notification),
            ),
          ),
        );
      },
    );
  }

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

  ToastificationItem showSimpleToast(
    String text, {
    Alignment alignment = Alignment.topCenter,
    Duration duration = const Duration(seconds: 4),
  }) {
    return toastification.showCustom(
      autoCloseDuration: duration,
      alignment: alignment,
      dismissDirection: DismissDirection.none,

      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },

      builder: (context, item) {
        return Align(
          alignment: item.alignment,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => toastification.dismiss(item),
              child: AppSimpleToast(text: text),
            ),
          ),
        );
      },
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
