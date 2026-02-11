part of 'notification_cubit.dart';

@freezed
sealed class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(false) bool isLoading,
    @Default([]) List<NotificationEntity> notifications,
    @Default(false) bool isPermissionGranted,
    String? token,
    String? error,
  }) = _NotificationState;
}
