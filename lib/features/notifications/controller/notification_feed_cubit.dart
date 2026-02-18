import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/notifications/data/repository/notification_repository.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';

part 'notification_feed_cubit.freezed.dart';
part 'notification_feed_state.dart';

@injectable
class NotificationFeedCubit extends Cubit<NotificationFeedState> {
  NotificationFeedCubit(this._repository, this._analytics) : super(const NotificationFeedState.initial());

  final NotificationRepository _repository;
  final AnalyticsService _analytics;

  int _page = 1;

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    final currentState = state;
    if (currentState case _Loaded(:final notifications) when notifications.isNotEmpty && !forceRefresh) {
      return;
    }
    if (currentState case _Loading()) return;

    if (!forceRefresh) {
      unawaited(_analytics.logEvent(AnalyticsEvents.notificationsView));
    }
    emit(const NotificationFeedState.loading());
    _page = 1;

    final result = await _repository.getNotifications(page: _page);

    if (isClosed) return;

    switch (result) {
      case Success(value: final data):
        emit(NotificationFeedState.loaded(
          notifications: data.items,
          hasMore: data.hasMore,
        ));
      case ErrorR(error: final e):
        emit(NotificationFeedState.error(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState case _Loaded(:final hasMore, :final isLoadingMore, :final notifications)) {
      if (!hasMore || isLoadingMore) return;
      emit(currentState.copyWith(isLoadingMore: true));
      _page++;
      unawaited(_fetchMore(notifications));
    }
  }

  Future<void> _fetchMore(List<NotificationEntity> existing) async {
    final result = await _repository.getNotifications(page: _page);

    if (isClosed) return;

    final currentState = state;
    if (currentState case _Loaded()) {
      switch (result) {
        case Success(value: final data):
          final merged = [...existing, ...data.items];
          emit(currentState.copyWith(
            notifications: merged,
            hasMore: data.hasMore,
            isLoadingMore: false,
          ));
        case ErrorR(error: final e):
          _page--;
          emit(currentState.copyWith(
            isLoadingMore: false,
            error: e.toString(),
          ));
      }
    }
  }

  void onRefresh() {
    unawaited(_analytics.logEvent(AnalyticsEvents.notificationsRefresh));
  }

  Future<void> clearNotification(int id) async {
    final currentState = state;
    if (currentState case _Loaded(:final notifications)) {
      unawaited(_analytics.logEvent(AnalyticsEvents.notificationsClearOne));
      final updated = notifications.where((n) => n.id != id).toList();
      emit(currentState.copyWith(notifications: updated));
      final result = await _repository.markNotificationAsRead(id);
      if (result case ErrorR(error: final e)) {
        emit(currentState.copyWith(notifications: notifications, error: e.toString()));
      }
    }
  }

  Future<void> clearAllNotifications() async {
    final currentState = state;
    if (currentState case _Loaded(:final notifications)) {
      unawaited(_analytics.logEvent(AnalyticsEvents.notificationsClearAll));
      emit(currentState.copyWith(notifications: []));
      final result = await _repository.markAllAsRead();
      if (result case ErrorR(error: final e)) {
        emit(currentState.copyWith(notifications: notifications, error: e.toString()));
      }
    }
  }
}
