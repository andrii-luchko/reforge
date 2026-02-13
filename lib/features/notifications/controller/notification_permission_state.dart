part of 'notification_permission_cubit.dart';

@freezed
sealed class NotificationPermissionState with _$NotificationPermissionState {
  const factory NotificationPermissionState.checking() = _Checking;

  const factory NotificationPermissionState.permissionNotDetermined() = _PermissionNotDetermined;

  const factory NotificationPermissionState.permissionDenied() = _PermissionDenied;

  const factory NotificationPermissionState.permissionGranted({
    String? token,
    @Default(false) bool isRequestingPermission,
  }) = _PermissionGranted;
}
