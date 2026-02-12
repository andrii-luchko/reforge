import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/achievements/ui/widgets/common_heder_delegate.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/ui/widgets/notification_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import 'package:reforge/shared/delete_wrapper.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

class NotificationListSection extends StatelessWidget {
  const NotificationListSection({
    required this.onClearAll,
    required this.onNotificationClear,
    required this.notifications,
    super.key,
  });

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  final List<NotificationEntity> notifications;
  final VoidCallback onClearAll;
  final ValueChanged<int> onNotificationClear;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final isEmpty = notifications.isEmpty;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: horizontalPadding.copyWith(top: 32, bottom: 16),
          sliver: SliverPersistentHeader(
            delegate: CommonHeaderDelegate(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notifications.length} items',
                    style: subheadH5Medium.copyWith(color: appTheme.beige700),
                  ),

                  ThirtyButton(
                    text: 'Clear all',
                    onPressed: onClearAll,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isEmpty)
          const SliverPadding(padding: horizontalPadding, sliver: NotificationListEmpty())
        else
          SliverPadding(
            padding: horizontalPadding,
            sliver: SliverList.separated(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return DeleteWrapper(
                  key: ValueKey(notification.id),
                  enabled: true,
                  onPressed: (context) {
                    onNotificationClear(notification.id);
                  },
                  label: t.common.clear_button,
                  child: NotificationListTile(notification: notification),
                ).animateEntrance();
              },
              separatorBuilder: (_, _) {
                return const SizedBox(height: 8);
              },
            ),
          ),
      ],
    );
  }
}

class NotificationListEmpty extends StatelessWidget {
  const NotificationListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverEmptyListMessage(
      icon: Icons.notifications_off_outlined,
      title: 'No notifications yet',
      subtitle:
          'You’re all caught up! Once there’s something new — like updates, reminders, or messages — you’ll see it here.',
    );
  }
}
