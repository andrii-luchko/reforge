import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/extensions/text_style_extension.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({required this.notification, super.key});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        border: Border.all(color: appTheme.strokeCard),
        borderRadius: .circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton.leaf(child: AppSvgListTileIcon.asset(asset: notification.type.iconAsset)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              mainAxisAlignment: .spaceBetween,
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: subheadH5Medium.copyWith(color: appTheme.beige100),
                        strutStyle: subheadH5Medium.strut,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.date.toNotificationTime(),
                      style: bodySRegular.copyWith(color: appTheme.beige700),
                      strutStyle: bodySRegular.strut,
                    ),
                  ],
                ),

                Text(
                  notification.subtitle,
                  style: bodyMRegular.copyWith(color: appTheme.beige600),
                  strutStyle: bodyMRegular.strut,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
