import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/notifications/data/repository/notification_repository.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';

part 'notification_cubit.freezed.dart';
part 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(const NotificationState());

  final NotificationRepository _repository;

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (state.isLoading || (state.notifications.isNotEmpty && !forceRefresh)) return;

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getNotifications();

    if (isClosed) return;

    switch (result) {
      case Success(value: final notifications):
        emit(state.copyWith(notifications: notifications, isLoading: false));
      case ErrorR(error: final error):
        emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  Future<void> clearNotification(int id) async {
    final oldNotifications = state.notifications;

    final newNotifications = oldNotifications.where((n) => n.id != id).toList();
    emit(state.copyWith(notifications: newNotifications));

    final result = await _repository.markNotificationAsRead(id);

    if (result case ErrorR(error: final error)) {
      emit(
        state.copyWith(
          notifications: oldNotifications,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> clearAllNotifications() async {
    final oldNotifications = state.notifications;

    emit(state.copyWith(notifications: []));

    final result = await _repository.markAllAsRead();

    if (result case ErrorR(error: final error)) {
      emit(
        state.copyWith(
          notifications: oldNotifications,
          error: error.toString(),
        ),
      );
    }
  }
}
