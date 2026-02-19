import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/notifications/controller/notification_feed_cubit.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/mock/notification_generator.dart';
import 'package:reforge/features/notifications/ui/widgets/notification_list_section.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationFeedCubit _cubit = context.read<NotificationFeedCubit>();
  final List<NotificationEntity> _mockedNotifications = NotificationGenerator.generateMocks(8);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    unawaited(_cubit.loadNotifications());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (maxScroll - currentScroll < 200) {
      unawaited(_cubit.loadMore());
    }
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
          child: BlocListener<NotificationFeedCubit, NotificationFeedState>(
            listenWhen: (prev, curr) {
              final currError = curr.when(
                initial: () => null,
                loading: () => null,
                loaded: (_, _, _, error) => error,
                error: (m) => m,
              );
              final prevError = prev.when(
                initial: () => null,
                loading: () => null,
                loaded: (_, _, _, error) => error,
                error: (m) => m,
              );
              return currError != null && currError != prevError;
            },
            listener: (context, state) {
              final message = state.when(
                initial: () => null,
                loading: () => null,
                loaded: (_, _, _, error) => error,
                error: (m) => m,
              );
              if (message != null) {
                toastification.showErrorToast(message, context);
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                _cubit.onRefresh();
                await _cubit.loadNotifications(forceRefresh: true);
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  DefaultSliverAppBar(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    title: t.notifications.pageTitle,
                  ),
                  BlocBuilder<NotificationFeedCubit, NotificationFeedState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => SliverSkeletonizer(
                          child: NotificationListSection(
                            notifications: _mockedNotifications,
                            onClearAll: () {},
                            onNotificationClear: (_) {},
                          ),
                        ),
                        loading: () => SliverSkeletonizer(
                          child: NotificationListSection(
                            notifications: _mockedNotifications,
                            onClearAll: () {},
                            onNotificationClear: (_) {},
                          ),
                        ),
                        loaded: (notifications, hasMore, isLoadingMore, error) => SliverMainAxisGroup(
                          slivers: [
                            _buildNotificationList(notifications: notifications),
                            if (isLoadingMore)
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                sliver: SliverToBoxAdapter(child: PaginationLoader()),
                              ),
                          ],
                        ),
                        error: (message) => SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(message),
                          ),
                        ),
                      );
                    },
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList({
    required List<NotificationEntity> notifications,
  }) {
    return SliverSkeletonizer(
      enabled: false,
      child: NotificationListSection(
        notifications: notifications,
        onClearAll: _cubit.clearAllNotifications,
        onNotificationClear: _cubit.clearNotification,
      ),
    );
  }
}
