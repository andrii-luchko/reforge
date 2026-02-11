import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/notifications/controller/notification_cubit.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/mock/notification_generator.dart';
import 'package:reforge/features/notifications/ui/widgets/notification_list_section.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationCubit cubit = context.read<NotificationCubit>();
  final List<NotificationEntity> mockedNotifications = NotificationGenerator.generateMocks(8);

  @override
  void initState() {
    super.initState();
    unawaited(cubit.loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => cubit.loadNotifications(forceRefresh: true),
            child: CustomScrollView(
              slivers: [
                DefaultSliverAppBar(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  title: 'Notification',
                ),
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    final displayedNotifications = state.isLoading ? mockedNotifications : state.notifications;
                    return SliverSkeletonizer(
                      enabled: state.isLoading,
                      child: NotificationListSection(
                        notifications: displayedNotifications,
                        onClearAll: cubit.clearAllNotifications,
                        onNotificationClear: cubit.clearNotification,
                      ),
                    );
                  },
                ),
                const SliverPadding(padding: .only(bottom: 50)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
