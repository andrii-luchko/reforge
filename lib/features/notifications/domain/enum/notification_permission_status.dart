enum NotificationPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}

extension NotificationPermissionStatusX on NotificationPermissionStatus {
  /// Returns true if notifications are fully authorized or provisional (iOS quiet delivery).
  bool get isGranted =>
      this == NotificationPermissionStatus.authorized || this == NotificationPermissionStatus.provisional;
}
